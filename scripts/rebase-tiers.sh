#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

BASE=main
DRY_RUN=0
AUTOSTASH=0
LOCKFILE=lazy-lock.json

declare -a BRANCHES=()

usage() {
    cat <<'EOF'
Usage: rebase-tiers.sh [options] [branch...]

Rebase the tier branches onto a base branch (default: main).

Each tier branch is a single commit that trims the plugin set. When a commit on
the base touches a file a tier deletes, the rebase stops on a modify/delete
conflict. The tier means for that file to stay deleted, so those are resolved
automatically.

lazy-lock.json conflicts are resolved too. It is a generated file, so it is
merged key by key rather than textually: the tier keeps its own plugin set, any
plugin newly added on the base is carried in, and pins come from the base since
it is the superset and holds the freshest commits. Needs python3.

Every other kind of conflict stops the script with the rebase left in progress
so you can finish it by hand.

Options:
  -b, --base <branch>   Base branch to rebase onto (default: main)
  -n, --dry-run         Report what would happen, change nothing
      --autostash       Stash local changes for the duration of the run
  -h, --help            Show this help

With no branch arguments, every local branch except the base is rebased.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--base)   BASE=${2:?--base needs a branch name}; shift 2 ;;
        -n|--dry-run) DRY_RUN=1; shift ;;
        --autostash) AUTOSTASH=1; shift ;;
        -h|--help)   usage; exit 0 ;;
        -*)          echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
        *)           BRANCHES+=("$1"); shift ;;
    esac
done


require_repo

require_base

for state in rebase-merge rebase-apply MERGE_HEAD CHERRY_PICK_HEAD; do
    [[ -e "$(git rev-parse --git-path $state)" ]] &&
        die "a rebase, merge or cherry-pick is already in progress; finish or abort it first"
done

collect_branches exclude-base
[[ ${#BRANCHES[@]} -eq 0 ]] && die "no branches to rebase"

ORIGINAL_BRANCH=$(git symbolic-ref --quiet --short HEAD || git rev-parse HEAD)

deleted_by_them() {
    local stages
    stages=$(git ls-files -u -- "$1" | awk '{print $3}' | sort -u | tr '\n' ' ')
    [[ "$stages" == *2* && "$stages" != *3* ]]
}

lockfile_mergeable() {
    [[ "$1" == "$LOCKFILE" ]] && command -v python3 >/dev/null 2>&1
}

merge_lockfile() {
    local path=$1 tmp rc
    tmp=$(mktemp -d)
    git show ":1:$path" > "$tmp/base"   2>/dev/null || printf '{\n}\n' > "$tmp/base"
    git show ":2:$path" > "$tmp/ours"   2>/dev/null || printf '{\n}\n' > "$tmp/ours"
    git show ":3:$path" > "$tmp/theirs" 2>/dev/null || printf '{\n}\n' > "$tmp/theirs"

    python3 - "$tmp" "$path" <<'PY'
import json, re, sys

tmp, path = sys.argv[1], sys.argv[2]
ENTRY = re.compile(r'^\s*("(?:[^"\\]|\\.)*")\s*:')

def entries(name):
    """Ordered [(key, raw_line)] for one merge stage."""
    out = []
    with open(f"{tmp}/{name}", encoding="utf-8") as fh:
        for line in fh.read().splitlines():
            m = ENTRY.match(line)
            if m:
                out.append((json.loads(m.group(1)), line.rstrip().rstrip(",")))
    return out

base, ours, theirs = entries("base"), entries("ours"), entries("theirs")
base_keys = {k for k, _ in base}
ours_map = dict(ours)
theirs_keys = {k for k, _ in theirs}

# a plugin the base gained since the merge base was never deleted by the tier
added_by_base = [k for k, _ in ours if k not in base_keys]
keep = theirs_keys | set(added_by_base)

merged = [(k, ln) for k, ln in ours if k in keep]          # base order + base pins
seen = {k for k, _ in merged}
merged += [(k, ln) for k, ln in theirs if k not in seen]   # tier-only leftovers

with open(path, "w", encoding="utf-8") as fh:
    fh.write("{\n")
    for i, (_, line) in enumerate(merged):
        fh.write(line + (",\n" if i < len(merged) - 1 else "\n"))
    fh.write("}\n")

print(f"{len(merged)} entries "
      f"({len(theirs_keys)} from tier, {len(added_by_base)} added by base)")
PY
    rc=$?
    rm -rf "$tmp"
    return $rc
}

tier_deletion_patch() {
    local path=$1 mode=$2 tmp rc=1
    tmp=$(mktemp -d)
    if ! git show ":1:$path" > "$tmp/base"   2>/dev/null ||
       ! git show ":2:$path" > "$tmp/ours"   2>/dev/null ||
       ! git show ":3:$path" > "$tmp/theirs" 2>/dev/null; then
        rm -rf "$tmp"; return 1
    fi

    diff -u "$tmp/base" "$tmp/theirs" > "$tmp/tier.patch" || true
    if grep -q '^+[^+]' "$tmp/tier.patch"; then
        rm -rf "$tmp"; return 1   # the tier adds lines too -- not a pure trim
    fi

    cp "$tmp/ours" "$tmp/result"
    local -a opts=(--silent --no-backup-if-mismatch -l -F 3)
    [[ "$mode" == "check" ]] && opts+=(--dry-run)
    if patch "${opts[@]}" "$tmp/result" < "$tmp/tier.patch" >/dev/null 2>&1; then
        [[ "$mode" == "apply" ]] && cp "$tmp/result" "$path"
        rc=0
    fi
    rm -rf "$tmp"
    return $rc
}

tier_deletion_satisfied() {
    local path=$1 tmp rc=1
    tmp=$(mktemp -d)
    if ! git show ":1:$path" > "$tmp/base"   2>/dev/null ||
       ! git show ":2:$path" > "$tmp/ours"   2>/dev/null ||
       ! git show ":3:$path" > "$tmp/theirs" 2>/dev/null; then
        rm -rf "$tmp"; return 1
    fi

    diff -u "$tmp/base" "$tmp/theirs" > "$tmp/tier.patch" || true
    if grep -q '^+[^+]' "$tmp/tier.patch"; then
        rm -rf "$tmp"; return 1
    fi

    rc=0
    while IFS= read -r line; do
        line=${line:1}
        [[ -z "${line//[[:space:]]/}" ]] && continue
        if grep -qxF -- "$line" "$tmp/ours"; then rc=1; break; fi
    done < <(grep '^-[^-]' "$tmp/tier.patch")

    rm -rf "$tmp"
    return $rc
}

# Why a file could not be resolved, so the report says what to look at.
stuck_reason() {
    local path=$1 tmp reason
    tmp=$(mktemp -d)
    if ! git show ":1:$path" > "$tmp/base" 2>/dev/null; then
        rm -rf "$tmp"; printf 'added on both sides'; return
    fi
    git show ":3:$path" > "$tmp/theirs" 2>/dev/null || true
    diff -u "$tmp/base" "$tmp/theirs" > "$tmp/p" 2>/dev/null || true
    if grep -q '^+[^+]' "$tmp/p"; then
        reason="the tier rewrites lines here"
    else
        reason="the tier's deletion no longer applies"
    fi
    rm -rf "$tmp"
    printf '%s' "$reason"
}

if [[ $DRY_RUN -eq 1 ]]; then
    info "Dry run: rebasing onto '$BASE' ($(git rev-parse --short "$BASE"))"
    for b in "${BRANCHES[@]}"; do
        merge_base=$(git merge-base "$BASE" "$b")
        if [[ "$merge_base" == "$(git rev-parse "$BASE")" ]]; then
            ok "$b is already on top of $BASE"
            continue
        fi
        mapfile -t base_touched < <(git diff --name-only "$merge_base" "$BASE")
        mapfile -t tier_deleted < <(git diff --name-status "$merge_base" "$b" | awk '$1=="D"{print $2}')
        overlap=()
        for f in "${base_touched[@]}"; do
            for d in "${tier_deleted[@]}"; do
                [[ "$f" == "$d" ]] && overlap+=("$f")
            done
        done
        info "$b: $(git rev-list --count "$merge_base..$b") commit(s) to replay"
        if [[ ${#overlap[@]} -gt 0 ]]; then
            warn "${#overlap[@]} modify/delete conflict(s) would be auto-resolved as deleted:"
            printf '          %s\n' "${overlap[@]}"
        else
            ok "no modify/delete conflicts predicted"
        fi
        if printf '%s\n' "${base_touched[@]}" | grep -qxF "$LOCKFILE" &&
           git diff --name-only "$merge_base" "$b" | grep -qxF "$LOCKFILE"; then
            if command -v python3 >/dev/null 2>&1; then
                warn "$LOCKFILE: both sides changed it, would be merged key-by-key"
            else
                fail "$LOCKFILE: both sides changed it and python3 is missing, would stop here"
            fi
        fi
    done
    exit 0
fi

if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
    if [[ $AUTOSTASH -eq 1 ]]; then
        info "Stashing local changes"
        git stash push --quiet --message "rebase-tiers autostash" --include-untracked
        STASHED=1
        trap 'if [[ ${STASHED:-0} -eq 1 ]]; then echo; info "Restoring stashed changes"; git stash pop --quiet || warn "could not pop stash automatically; see: git stash list"; fi' EXIT
    else
        die "working tree has uncommitted changes; commit, stash, or re-run with --autostash"
    fi
fi

BACKUP=$(git rev-parse --git-path tier-rebase-backup)
: > "$BACKUP"
for b in "${BRANCHES[@]}"; do
    printf 'git branch -f %s %s\n' "$b" "$(git rev-parse "$b")" >> "$BACKUP"
done
info "Saved pre-rebase positions to $BACKUP"

rebase_one() {
    local branch=$1 auto=0 locks=0 trimmed=0 kept=0 moot=0 guard=0

    git checkout --quiet "$branch"

    if git rebase --quiet "$BASE" 2>/dev/null; then
        ok "$branch"
        return 0
    fi

    while [[ -e "$(git rev-parse --git-path rebase-merge)" || -e "$(git rev-parse --git-path rebase-apply)" ]]; do
        guard=$((guard + 1))
        if [[ $guard -gt 100 ]]; then
            fail "$branch: too many conflict rounds, stopping"
            return 1
        fi

        local -a unmerged=() resolvable=() shared=() lockfiles=() trims=() satisfied=() stuck=()
        mapfile -t unmerged < <(git diff --name-only --diff-filter=U)

        if [[ ${#unmerged[@]} -eq 0 ]]; then
            if git diff --cached --quiet; then
                GIT_EDITOR=true git rebase --skip >/dev/null 2>&1 || true
            else
                GIT_EDITOR=true git rebase --continue >/dev/null 2>&1 || true
            fi
            continue
        fi

        for f in "${unmerged[@]}"; do
            if deleted_by_them "$f"; then
                resolvable+=("$f")
            elif shared_path "$f"; then
                shared+=("$f")
            elif lockfile_mergeable "$f"; then
                lockfiles+=("$f")
            elif tier_deletion_patch "$f" check; then
                trims+=("$f")
            elif tier_deletion_satisfied "$f"; then
                satisfied+=("$f")
            else
                stuck+=("$f")
            fi
        done

        for f in "${resolvable[@]}"; do
            git rm --quiet --force -- "$f"
            auto=$((auto + 1))
        done

        for f in "${shared[@]}"; do
            git checkout --ours -- "$f"
            git add -- "$f"
            kept=$((kept + 1))
            warn "$branch: kept the base's version of $f (shared across tiers)"
        done

        for f in "${trims[@]}"; do
            if ! tier_deletion_patch "$f" apply; then
                fail "$branch: could not re-apply the tier's deletion to $f"
                return 1
            fi
            git add -- "$f"
            trimmed=$((trimmed + 1))
            warn "$branch: re-applied the tier's own deletion to $f"
        done

        for f in "${lockfiles[@]}"; do
            local summary
            if ! summary=$(merge_lockfile "$f"); then
                fail "$branch: could not merge $f"
                return 1
            fi
            git add -- "$f"
            locks=$((locks + 1))
            warn "$branch: merged $f -- $summary"
        done

        for f in "${satisfied[@]}"; do
            git checkout --ours -- "$f"
            git add -- "$f"
            moot=$((moot + 1))
            warn "$branch: kept the base's version of $f (the tier's trim is already applied)"
        done

        if [[ ${#stuck[@]} -gt 0 ]]; then
            fail "$branch: resolved everything it could; these need you:"
            for f in "${stuck[@]}"; do
                printf '          %-46s %s\n' "$f" "$(stuck_reason "$f")"
            done
            return 1
        fi

        if git diff --cached --quiet; then
            GIT_EDITOR=true git rebase --skip >/dev/null 2>&1 || true
        else
            GIT_EDITOR=true git rebase --continue >/dev/null 2>&1 || true
        fi
    done

    ok "$branch (auto-resolved $auto modify/delete conflict(s) as deleted, replayed $trimmed tier trim(s), dropped $moot moot trim(s), kept $kept shared file(s), merged $locks lockfile(s))"
    return 0
}

info "Rebasing onto '$BASE' ($(git rev-parse --short "$BASE"))"
declare -a FAILED=()
for b in "${BRANCHES[@]}"; do
    if ! rebase_one "$b"; then
        FAILED+=("$b")
        break
    fi
done

if [[ ${#FAILED[@]} -gt 0 ]]; then
    echo
    die "stopped on '${FAILED[0]}' with the rebase in progress.
  Everything else is already resolved and staged.
  Resolve the files listed above, then: git rebase --continue
  To give up on this branch:              git rebase --abort
  To undo every branch this run moved:    sh $BACKUP"
fi

git checkout --quiet "$ORIGINAL_BRANCH"

echo
info "Summary"
printf '  %-14s %s\n' "$BASE" "$(git rev-parse --short "$BASE")"
for b in "${BRANCHES[@]}"; do
    printf '  %-14s %s  (%s commit(s) on top of %s)\n' \
        "$b" "$(git rev-parse --short "$b")" "$(git rev-list --count "$BASE..$b")" "$BASE"
done
echo
info "Undo this run with: sh $BACKUP"
