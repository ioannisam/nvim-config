#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

REMOTE=origin
BASE=main
DRY_RUN=0
ASSUME_YES=0
VERIFY=1
ALLOW_FOREIGN=0
declare -a BRANCHES=()

usage() {
    cat <<'EOF'
Usage: push-tiers.sh [options] [branch...]

Publish the base and the tier branches to the remote.

Rebasing rewrites every tier, so their history diverges from what the remote
already has and a plain push is refused. This pushes each branch the gentlest
way that works: a normal push where the remote can fast-forward, and a lease-
guarded force only where the rebase actually rewrote history.

Before anything is pushed the tiers are verified with check-tiers.sh, the
remote is fetched, and every commit a force would discard is checked against
this branch's reflog. Commits the branch used to point at are the rebase's own
leftovers and are listed for confirmation; a commit the branch has never held
came from somewhere else, and the push stops rather than destroy it.

Options:
  -r, --remote <name>   Remote to push to (default: origin)
  -b, --base <branch>   Branch the tiers sit on (default: main)
  -n, --dry-run         Show what would be pushed, push nothing
  -y, --yes             Do not ask before discarding your own replaced commits
      --allow-foreign   Discard remote commits this branch never held (dangerous)
      --no-verify       Skip check-tiers.sh
  -h, --help            Show this help

With no branch arguments, every local branch is pushed.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -r|--remote)  REMOTE=${2:?--remote needs a name}; shift 2 ;;
        -b|--base)    BASE=${2:?--base needs a branch name}; shift 2 ;;
        -n|--dry-run) DRY_RUN=1; shift ;;
        -y|--yes)     ASSUME_YES=1; shift ;;
        --no-verify)  VERIFY=0; shift ;;
        --allow-foreign) ALLOW_FOREIGN=1; shift ;;
        -h|--help)    usage; exit 0 ;;
        -*)           echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
        *)            BRANCHES+=("$1"); shift ;;
    esac
done


require_repo
git remote get-url "$REMOTE" >/dev/null 2>&1 || die "no remote named '$REMOTE'"
require_base

collect_branches

# Push the base first so the tiers never point at commits the remote lacks.
declare -a ORDERED=()
for b in "${BRANCHES[@]}"; do [[ "$b" == "$BASE" ]] && ORDERED+=("$b"); done
for b in "${BRANCHES[@]}"; do [[ "$b" != "$BASE" ]] && ORDERED+=("$b"); done

if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
    warn "working tree has uncommitted changes; they will not be pushed"
fi

if [[ $VERIFY -eq 1 ]]; then
    checker="$(dirname "$0")/check-tiers.sh"
    if [[ -x "$checker" ]]; then
        info "Verifying the branches first"
        "$checker" -q -b "$BASE" || die "check-tiers.sh failed; fix the branches before publishing"
        ok "branches verified"
    else
        warn "check-tiers.sh not found or not executable, skipping verification"
    fi
fi

info "Fetching $REMOTE"
git fetch --quiet "$REMOTE"

# A commit we are about to drop is only safe to drop if this branch pointed at
# it before -- that makes it a position the rebase replaced. Anything else
# reached the remote from somewhere we have never been, so it is someone
# else's work and must not be discarded on our say-so.
#
# The lease alone cannot tell the difference: it is pinned to what the fetch
# just saw, so it agrees with whatever is on the remote, including a commit
# pushed a second ago.
ours_already() {
    local sha=$1 branch=$2 old
    while read -r old; do
        [[ -z "$old" ]] && continue
        git merge-base --is-ancestor "$sha" "$old" 2>/dev/null && return 0
    done < <(git reflog show --format='%H' "$branch" 2>/dev/null)
    return 1
}

# Decide, per branch, the gentlest push that will work.
declare -a PLAN_BRANCH=() PLAN_MODE=() PLAN_LEASE=()
declare -a DISCARDS=() FOREIGN=()
NEEDS_FORCE=0

for b in "${ORDERED[@]}"; do
    local_sha=$(git rev-parse "$b")
    remote_ref="refs/remotes/$REMOTE/$b"

    if ! git show-ref --verify --quiet "$remote_ref"; then
        PLAN_BRANCH+=("$b"); PLAN_MODE+=("new"); PLAN_LEASE+=("")
        continue
    fi

    remote_sha=$(git rev-parse "$remote_ref")
    if [[ "$local_sha" == "$remote_sha" ]]; then
        PLAN_BRANCH+=("$b"); PLAN_MODE+=("current"); PLAN_LEASE+=("")
    elif [[ "$(git merge-base "$local_sha" "$remote_sha")" == "$remote_sha" ]]; then
        PLAN_BRANCH+=("$b"); PLAN_MODE+=("fast-forward"); PLAN_LEASE+=("")
    else
        PLAN_BRANCH+=("$b"); PLAN_MODE+=("force"); PLAN_LEASE+=("$remote_sha")
        NEEDS_FORCE=1
        while read -r sha subject; do
            [[ -z "$sha" ]] && continue
            if ours_already "$sha" "$b"; then
                DISCARDS+=("$b: ${sha:0:9} $subject")
            else
                FOREIGN+=("$b: ${sha:0:9} $subject")
            fi
        done < <(git log --format='%H %s' "$local_sha..$remote_sha")
    fi
done

info "Plan for $REMOTE ($(git remote get-url "$REMOTE"))"
for i in "${!PLAN_BRANCH[@]}"; do
    b=${PLAN_BRANCH[i]} mode=${PLAN_MODE[i]}
    case "$mode" in
        current)      printf '  %-12s %s\n' "$b" "already up to date" ;;
        new)          printf '  %-12s %s\n' "$b" "new branch on the remote" ;;
        fast-forward) printf '  %-12s %s\n' "$b" \
                        "fast-forward, +$(git rev-list --count "$REMOTE/$b..$b") commit(s)" ;;
        force)        printf '  %-12s \033[1;33m%s\033[0m\n' "$b" \
                        "force (rewritten): +$(git rev-list --count "$REMOTE/$b..$b") new, -$(git rev-list --count "$b..$REMOTE/$b") discarded" ;;
    esac
done

if [[ ${#DISCARDS[@]} -gt 0 ]]; then
    echo
    warn "dropping these commits, each one a position this branch used to hold:"
    printf '          %s\n' "${DISCARDS[@]}"
fi

if [[ ${#FOREIGN[@]} -gt 0 ]]; then
    echo
    fail "the remote has commits this branch has never pointed at:"
    printf '          %s\n' "${FOREIGN[@]}"
    echo "          Someone else pushed these, or they were made in another clone."
    echo "          Fetch and replay your work on top of them instead of forcing."
    if [[ $ALLOW_FOREIGN -eq 0 ]]; then
        echo
        die "refusing to discard work this branch never had (--allow-foreign overrides)"
    fi
    warn "--allow-foreign given, discarding them anyway"
fi

if [[ $DRY_RUN -eq 1 ]]; then
    echo
    info "Dry run, nothing pushed"
    exit 0
fi

if [[ $NEEDS_FORCE -eq 1 && $ASSUME_YES -eq 0 ]]; then
    echo
    printf 'Rewrite the branches listed above on %s? [y/N] ' "$REMOTE"
    read -r reply </dev/tty || reply=""
    [[ "$reply" == [yY] || "$reply" == [yY][eE][sS] ]] || die "aborted, nothing pushed"
fi

echo
info "Pushing"
declare -a FAILED=()
for i in "${!PLAN_BRANCH[@]}"; do
    b=${PLAN_BRANCH[i]} mode=${PLAN_MODE[i]} lease=${PLAN_LEASE[i]}

    if [[ "$mode" == "current" ]]; then
        ok "$b (nothing to do)"
        continue
    fi

    if [[ "$mode" == "force" ]]; then
        # Pin the lease to what the fetch saw, so a branch that moved since
        # then is rejected instead of overwritten.
        if git push --quiet --force-with-lease="refs/heads/$b:$lease" "$REMOTE" "$b:refs/heads/$b"; then
            ok "$b (rewritten)"
        else
            fail "$b: the remote moved since the fetch; re-run to see the new state"
            FAILED+=("$b")
        fi
    else
        if git push --quiet --set-upstream "$REMOTE" "$b:refs/heads/$b" >/dev/null 2>&1; then
            ok "$b"
        else
            fail "$b: push rejected"
            FAILED+=("$b")
        fi
    fi
done

echo
if [[ ${#FAILED[@]} -gt 0 ]]; then
    die "${#FAILED[@]} branch(es) failed to push: ${FAILED[*]}"
fi
info "All branches published to $REMOTE"
