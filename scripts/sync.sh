#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

REMOTE=origin
BASE=main
DRY_RUN=0
ASSUME_YES=0
AUTOSTASH=0
DO_VERIFY=1
DO_PUSH=1

usage() {
    cat <<'EOF'
Usage: sync.sh [options]

Rebase the tier branches onto the base, verify them, and publish them.

Runs the three scripts in the only order that makes sense, and stops at the
first one that fails so a broken tier is never verified against and never
pushed:

    rebase-tiers.sh   replay each tier on the base
    check-tiers.sh    make sure the result still loads
    push-tiers.sh     publish, forcing only where a rebase rewrote history

Options:
  -r, --remote <name>   Remote to push to (default: origin)
  -b, --base <branch>   Branch the tiers sit on (default: main)
  -n, --dry-run         Report what each stage would do, change nothing
  -y, --yes             Do not ask before discarding your own replaced commits
      --autostash       Stash local changes for the duration of the rebase
      --no-verify       Skip check-tiers.sh (not recommended)
      --no-push         Stop after verifying, publish nothing
  -h, --help            Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -r|--remote)  REMOTE=${2:?--remote needs a name}; shift 2 ;;
        -b|--base)    BASE=${2:?--base needs a branch name}; shift 2 ;;
        -n|--dry-run) DRY_RUN=1; shift ;;
        -y|--yes)     ASSUME_YES=1; shift ;;
        --autostash)  AUTOSTASH=1; shift ;;
        --no-verify)  DO_VERIFY=0; shift ;;
        --no-push)    DO_PUSH=0; shift ;;
        -h|--help)    usage; exit 0 ;;
        *)            echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

step() { printf '\n\033[1;35m━━ %s\033[0m\n' "$*"; }

for s in rebase-tiers.sh check-tiers.sh push-tiers.sh; do
    [[ -x "$SCRIPT_DIR/$s" ]] || die "$SCRIPT_DIR/$s is missing or not executable"
done

require_repo

declare -a REBASE_ARGS=(-b "$BASE")
[[ $DRY_RUN -eq 1 ]] && REBASE_ARGS+=(--dry-run)
[[ $AUTOSTASH -eq 1 ]] && REBASE_ARGS+=(--autostash)

# push-tiers.sh runs the checker itself
declare -a PUSH_ARGS=(-b "$BASE" -r "$REMOTE" --no-verify)
[[ $DRY_RUN -eq 1 ]] && PUSH_ARGS+=(--dry-run)
[[ $ASSUME_YES -eq 1 ]] && PUSH_ARGS+=(-y)

step "1/3  rebase onto $BASE"
"$SCRIPT_DIR/rebase-tiers.sh" "${REBASE_ARGS[@]}" \
    || die "rebase stopped; resolve the conflict, finish with 'git rebase --continue', then re-run sync"

if [[ $DO_VERIFY -eq 1 ]]; then
    step "2/3  verify"
    if [[ $DRY_RUN -eq 1 ]]; then
        # Nothing was rebased, so "not on top of base" is expected here and
        # says nothing about what the real run would produce.
        "$SCRIPT_DIR/check-tiers.sh" -q -b "$BASE" || info "expected while dry running: the tiers have not been moved"
    else
        "$SCRIPT_DIR/check-tiers.sh" -q -b "$BASE" \
            || die "the rebased branches did not verify; nothing was pushed"
    fi
else
    step "2/3  verify (skipped)"
fi

if [[ $DO_PUSH -eq 1 ]]; then
    step "3/3  publish to $REMOTE"
    "$SCRIPT_DIR/push-tiers.sh" "${PUSH_ARGS[@]}" || die "publish failed; the branches are rebased and verified locally"
else
    step "3/3  publish (skipped)"
fi

step "summary"
printf '  %-14s %s\n' "$BASE" "$(git rev-parse --short "$BASE")"
for b in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
    [[ "$b" == "$BASE" ]] && continue
    sync_state="local only"
    if git show-ref --verify --quiet "refs/remotes/$REMOTE/$b"; then
        if [[ "$(git rev-parse "$b")" == "$(git rev-parse "$REMOTE/$b")" ]]; then
            sync_state="in sync with $REMOTE"
        else
            sync_state="differs from $REMOTE"
        fi
    fi
    printf '  %-14s %s  (%s commit(s) on %s, %s)\n' \
        "$b" "$(git rev-parse --short "$b")" "$(git rev-list --count "$BASE..$b")" "$BASE" "$sync_state"
done

echo
if [[ $DRY_RUN -eq 1 ]]; then
    info "Dry run finished, nothing changed"
else
    info "Done"
fi
