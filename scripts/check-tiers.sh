#!/usr/bin/env bash
set -euo pipefail

BASE=main
QUIET=0
declare -a BRANCHES=()
declare -a TIER_ORDER=(tiny minimal standard verbose)
declare -a SHARED_PATHS=("lua/utils/*")
declare -a REQUIRES=(
    "lua/plugins/editor/illuminate.lua|'lsp',|lua/plugins/lsp/lspconfig.lua|illuminate lsp provider"
    "lua/plugins/editor/illuminate.lua|'treesitter',|lua/plugins/editor/treesitter.lua|illuminate treesitter provider"
    "lua/plugins/ui/satellite.lua|signs = { add|lua/plugins/git/gitsigns.lua|satellite gitsigns handler"
    "lua/plugins/ui/satellite.lua|min_severity|lua/plugins/lsp/lspconfig.lua|satellite diagnostic handler"
    "lua/plugins/ui/lualine.lua|harpoons|lua/plugins/navigation/harpoon.lua|lualine harpoon component"
    "lua/plugins/ui/lualine.lua|\"diagnostics\"|lua/plugins/lsp/lspconfig.lua|lualine diagnostics component"
    "lua/plugins/ui/lualine.lua|\"diff\"|lua/plugins/git/gitsigns.lua|lualine diff component"
    "lua/plugins/navigation/bufferline.lua|diagnostics = \"nvim_lsp\"|lua/plugins/lsp/lspconfig.lua|bufferline lsp diagnostics"
)

usage() {
    cat <<'EOF'
Usage: check-tiers.sh [options] [branch...]

Verify the tier branches without checking any of them out.

Each branch is extracted to a temporary directory and checked for the mistakes
a rebase can leave behind: conflict markers, Lua that no longer parses, plugin
directories a tier emptied but lazy.nvim still imports, requires pointing at
modules a tier deleted, shared utils that drifted from the base, and config
that references a plugin its own tier removed.

Exits non-zero if anything fails, so it can follow a rebase directly:

    ./scripts/rebase-tiers.sh && ./scripts/check-tiers.sh

The documentation check is advisory and partial: it only sees rows whose Plugin
column names the plugin, so a keymap listed under a category such as "General"
is not matched. Treat a clean docs line as "nothing obvious", not as proof.

Options:
  -b, --base <branch>   Branch the tiers sit on (default: main)
  -q, --quiet           Only report problems
  -h, --help            Show this help

With no branch arguments, the base and every local branch are checked.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--base)    BASE=${2:?--base needs a branch name}; shift 2 ;;
        -q|--quiet)   QUIET=1; shift ;;
        -h|--help)    usage; exit 0 ;;
        -*)           echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
        *)            BRANCHES+=("$1"); shift ;;
    esac
done

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { [[ $QUIET -eq 1 ]] || printf '  \033[1;32mok\033[0m    %s\n' "$*"; }
warn() { printf '  \033[1;33mwarn\033[0m  %s\n' "$*"; }
bad()  { printf '  \033[1;31mfail\033[0m  %s\n' "$*"; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

PROBLEMS=0
WARNINGS=0
fail() { bad "$*"; PROBLEMS=$((PROBLEMS + 1)); }
soft() { warn "$*"; WARNINGS=$((WARNINGS + 1)); }

git rev-parse --git-dir >/dev/null 2>&1 || die "not inside a git repository"
cd "$(git rev-parse --show-toplevel)"
git show-ref --verify --quiet "refs/heads/$BASE" || die "base branch '$BASE' does not exist"

if [[ ${#BRANCHES[@]} -eq 0 ]]; then
    mapfile -t BRANCHES < <(git for-each-ref --format='%(refname:short)' refs/heads/)
fi
for b in "${BRANCHES[@]}"; do
    git show-ref --verify --quiet "refs/heads/$b" || die "branch '$b' does not exist"
done

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

for b in "${BRANCHES[@]}"; do
    mkdir -p "$TMP/$b"
    git archive "$b" | tar -x -C "$TMP/$b"
done

# Every Lua file has to load under the same LuaJIT Neovim will use.
parse_tree() {
    local dir=$1
    if ! command -v nvim >/dev/null 2>&1; then
        printf 'SKIP'
        return
    fi
    nvim --headless -l /dev/stdin "$dir" <<'LUA' 2>/dev/null
local dir = _G.arg[1]
local bad = {}
for _, f in ipairs(vim.fn.systemlist("find " .. vim.fn.shellescape(dir) .. "/lua -name '*.lua' 2>/dev/null")) do
    local chunk, err = loadfile(f)
    if not chunk then
        table.insert(bad, f:gsub("^" .. vim.pesc(dir) .. "/", "") .. ": " .. tostring(err))
    end
end
io.write(table.concat(bad, "\n"))
LUA
}

info "Checking against '$BASE' ($(git rev-parse --short "$BASE"))"

for b in "${BRANCHES[@]}"; do
    d="$TMP/$b"
    printf '\n\033[1m%s\033[0m (%s)\n' "$b" "$(git rev-parse --short "$b")"

    # sits on the base
    if [[ "$b" != "$BASE" ]]; then
        if [[ "$(git merge-base "$BASE" "$b")" == "$(git rev-parse "$BASE")" ]]; then
            ok "on top of $BASE ($(git rev-list --count "$BASE..$b") commit(s))"
        else
            fail "not on top of $BASE -- rebase it"
        fi
    fi

    # no conflict markers
    markers=$(grep -rlE '^(<<<<<<< |>>>>>>> |\|\|\|\|\|\|\| )' "$d" 2>/dev/null | sed "s|$d/||" || true)
    if [[ -n "$markers" ]]; then
        fail "conflict markers left in: $(echo "$markers" | tr '\n' ' ')"
    else
        ok "no conflict markers"
    fi

    # every Lua file parses
    parse_out=$(parse_tree "$d" || true)
    count=$(find "$d/lua" -name '*.lua' 2>/dev/null | wc -l || true)
    if [[ "$parse_out" == "SKIP" ]]; then
        soft "nvim not found, skipped the parse check"
    elif [[ -n "$parse_out" ]]; then
        fail "Lua that does not parse:"
        printf '          %s\n' "$parse_out"
    else
        ok "$count Lua file(s) parse"
    fi

    # lazy.nvim imports point at directories that still have specs
    if [[ -f "$d/lua/config/lazy.lua" ]]; then
        empty=""
        while read -r imp; do
            [[ -z "$imp" ]] && continue
            sub="$d/lua/${imp//./\/}"
            # A glob into a missing directory must not abort the run: this is
            # the very failure the check exists to report.
            shopt -s nullglob
            specs=("$sub"/*.lua)
            shopt -u nullglob
            [[ ${#specs[@]} -eq 0 ]] && empty="$empty $imp"
        done < <(grep -oP '(?<=import = ")[^"]+' "$d/lua/config/lazy.lua" || true)
        if [[ -n "$empty" ]]; then
            fail "lazy.lua imports nothing-directories:$empty"
        else
            ok "all lazy.lua imports resolve"
        fi
    fi

    # require("utils.x") targets exist
    missing=""
    while read -r m; do
        [[ -z "$m" ]] && continue
        f="$d/lua/${m//./\/}.lua"
        [[ -f "$f" ]] || missing="$missing $m"
    done < <(grep -rhoP 'require\("\Kutils\.[a-z_]+(?=")' "$d/lua" 2>/dev/null | sort -u || true)
    if [[ -n "$missing" ]]; then
        fail "require() targets that do not exist:$missing"
    else
        ok "all utils requires resolve"
    fi

    # shared files match the base
    if [[ "$b" != "$BASE" ]]; then
        drifted=""
        for pat in "${SHARED_PATHS[@]}"; do
            while read -r f; do
                [[ -z "$f" ]] && continue
                git diff --quiet "$BASE" "$b" -- "$f" || drifted="$drifted $f"
            done < <(git ls-tree -r --name-only "$b" | grep -E "^${pat//\*/[^/]*}$" || true)
        done
        if [[ -n "$drifted" ]]; then
            fail "shared file(s) drifted from $BASE:$drifted"
        else
            ok "shared files match $BASE"
        fi
    fi

    # config that needs a plugin the tier dropped
    dangling=""
    for spec in "${REQUIRES[@]}"; do
        IFS='|' read -r file pattern needs label <<<"$spec"
        [[ -f "$d/$file" ]] || continue
        grep -qF -- "$pattern" "$d/$file" 2>/dev/null || continue
        [[ -f "$d/$needs" ]] || dangling="$dangling|$label"
    done
    if [[ -n "$dangling" ]]; then
        fail "config referencing absent plugins:$(echo "$dangling" | tr '|' ' ')"
    else
        ok "no config referencing absent plugins"
    fi

    # docs mentioning plugins this tier removed (advisory)
    if [[ "$b" != "$BASE" && -f "$d/doc/keymaps.md" ]]; then
        stale=""
        while read -r spec; do
            [[ -z "$spec" ]] && continue
            [[ -f "$d/$spec" ]] && continue
            repo=$(git show "$BASE:$spec" | grep -oP '^\s*"\K[^"]+/[^"]+' | head -1 || true)
            [[ -z "$repo" ]] && continue

            if grep -qE "\|[[:space:]]*(${repo//\//\\/}|${repo##*/})[[:space:]]*\|" \
                   "$d/doc/keymaps.md" 2>/dev/null; then
                stale="$stale ${repo##*/}"
            fi
        done < <(git ls-tree -r --name-only "$BASE" -- lua/plugins)
        if [[ -n "$stale" ]]; then
            soft "doc/keymaps.md still mentions removed plugin(s):$stale"
        else
            ok "docs mention no removed plugins"
        fi
    fi
done

# plugin sets are nested
printf '\n\033[1mnesting\033[0m\n'
declare -a CHAIN=()
for t in "${TIER_ORDER[@]}"; do
    git show-ref --verify --quiet "refs/heads/$t" && CHAIN+=("$t")
done
CHAIN+=("$BASE")
if [[ ${#CHAIN[@]} -lt 2 ]]; then
    soft "no tier chain to check"
else
    for ((i = 0; i < ${#CHAIN[@]} - 1; i++)); do
        small=${CHAIN[i]} large=${CHAIN[i + 1]}
        extra=$(comm -23 \
            <(git ls-tree -r --name-only "$small" -- lua/plugins | sort) \
            <(git ls-tree -r --name-only "$large" -- lua/plugins | sort))
        if [[ -n "$extra" ]]; then
            fail "$small has specs $large lacks: $(echo "$extra" | tr '\n' ' ')"
        else
            ok "$small ⊆ $large"
        fi
    done
fi

printf '\n'
if [[ $PROBLEMS -eq 0 ]]; then
    info "All checks passed${WARNINGS:+ ($WARNINGS warning(s))}"
    exit 0
fi
die "$PROBLEMS problem(s) found${WARNINGS:+, $WARNINGS warning(s)}"
