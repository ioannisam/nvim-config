# shellcheck shell=bash
# Shared by the tier scripts. Source it, do not execute it.
#
#   source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
#
# Several helpers read the caller's BASE and BRANCHES variables rather than
# taking them as arguments, because every script already keeps them under those
# names and threading them through added noise without adding clarity.

# ── output ──────────────────────────────────────────────────────────────────
# `ok` is silenced by QUIET so a script can offer -q without the others caring.
: "${QUIET:=0}"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { [[ $QUIET -eq 1 ]] || printf '  \033[1;32mok\033[0m    %s\n' "$*"; }
warn() { printf '  \033[1;33mwarn\033[0m  %s\n' "$*"; }
fail() { printf '  \033[1;31mfail\033[0m  %s\n' "$*"; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# ── git ─────────────────────────────────────────────────────────────────────
require_repo() {
    git rev-parse --git-dir >/dev/null 2>&1 || die "not inside a git repository"
    cd "$(git rev-parse --show-toplevel)" || die "cannot enter the repository root"
}

require_branch() {
    git show-ref --verify --quiet "refs/heads/$1" || die "branch '$1' does not exist"
}

require_base() {
    git show-ref --verify --quiet "refs/heads/$BASE" || die "base branch '$BASE' does not exist"
}

# Fill BRANCHES from the local branches when the caller passed none, then make
# sure every name really exists. Pass "exclude-base" for scripts that operate
# on the tiers only.
collect_branches() {
    local mode=${1:-} b
    if [[ ${#BRANCHES[@]} -eq 0 ]]; then
        if [[ "$mode" == "exclude-base" ]]; then
            mapfile -t BRANCHES < <(git for-each-ref --format='%(refname:short)' refs/heads/ | grep -vxF "$BASE" || true)
        else
            mapfile -t BRANCHES < <(git for-each-ref --format='%(refname:short)' refs/heads/)
        fi
    fi
    for b in "${BRANCHES[@]}"; do
        require_branch "$b"
    done
}

# ── tier configuration ──────────────────────────────────────────────────────
# Files every tier takes from the base verbatim. Globs, matched whole.
declare -a SHARED_PATHS=("lua/utils/*")

# Smallest to largest; each tier's plugin set must be a subset of the next.
# shellcheck disable=SC2034  # read by check-tiers.sh
declare -a TIER_ORDER=(tiny minimal standard verbose)

shared_path() {
    local f=$1 p
    for p in "${SHARED_PATHS[@]}"; do
        # shellcheck disable=SC2053  # unquoted on purpose: $p is a glob
        [[ "$f" == $p ]] && return 0
    done
    return 1
}
