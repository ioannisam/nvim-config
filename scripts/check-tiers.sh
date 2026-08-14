#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

BASE=main
QUIET=0
declare -a BRANCHES=()
declare -a REQUIRES=(
    "lua/plugins/editor/illuminate.lua|'lsp',|lua/plugins/lsp/lspconfig.lua|illuminate lsp provider"
    "lua/plugins/editor/illuminate.lua|'treesitter',|lua/plugins/editor/treesitter.lua|illuminate treesitter provider"
    "lua/plugins/ui/satellite.lua|signs = { add|lua/plugins/git/gitsigns.lua|satellite gitsigns handler"
    "lua/plugins/ui/satellite.lua|min_severity|lua/plugins/lsp/lspconfig.lua|satellite diagnostic handler"
    "lua/plugins/ui/lualine.lua|harpoons|lua/plugins/navigation/harpoon.lua|lualine harpoon component"
    "lua/plugins/ui/lualine.lua|\"diagnostics\"|lua/plugins/lsp/lspconfig.lua|lualine diagnostics component"
    "lua/plugins/ui/lualine.lua|\"diff\"|lua/plugins/git/gitsigns.lua|lualine diff component"
    "lua/plugins/navigation/bufferline.lua|diagnostics = \"nvim_lsp\"|lua/plugins/lsp/lspconfig.lua|bufferline lsp diagnostics"

    "lua/utils/picker.lua|require(\"telescope|lua/plugins/navigation/telescope.lua|utils.picker needs telescope"
    "lua/plugins/editor/yanky.lua|require(\"telescope\")|lua/plugins/navigation/telescope.lua|yanky yank-history extension needs telescope"
    "lua/plugins/navigation/harpoon.lua|require(\"telescope|lua/plugins/navigation/telescope.lua|harpoon picker needs telescope"
    "lua/plugins/navigation/project.lua|require(\"telescope\")|lua/plugins/navigation/telescope.lua|project picker needs telescope"
    "lua/plugins/ui/alpha.lua|require(\"persistence\")|lua/plugins/navigation/persistence.lua|alpha session button needs persistence"
    "lua/plugins/ui/bqf.lua|require(\"catppuccin.palettes\")|lua/plugins/ui/catppuccin.lua|bqf highlights need catppuccin"
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

doc/commands.md names each plugin as `owner/repo`, so that check is exact and
a hit fails the run. doc/keymaps.md only names the plugin in some of its
tables, so a hit is reported as a warning but a clean result there means
"nothing obvious", not "nothing wrong".

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


PROBLEMS=0
WARNINGS=0
problem() { fail "$*"; PROBLEMS=$((PROBLEMS + 1)); }
soft() { warn "$*"; WARNINGS=$((WARNINGS + 1)); }

require_repo
require_base

collect_branches

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
            problem "not on top of $BASE -- rebase it"
        fi
    fi

    # no conflict markers
    markers=$(grep -rlE '^(<<<<<<< |>>>>>>> |\|\|\|\|\|\|\| )' "$d" 2>/dev/null | sed "s|$d/||" || true)
    if [[ -n "$markers" ]]; then
        problem "conflict markers left in: $(echo "$markers" | tr '\n' ' ')"
    else
        ok "no conflict markers"
    fi

    # every Lua file parses
    parse_out=$(parse_tree "$d" || true)
    count=$(find "$d/lua" -name '*.lua' 2>/dev/null | wc -l || true)
    if [[ "$parse_out" == "SKIP" ]]; then
        soft "nvim not found, skipped the parse check"
    elif [[ -n "$parse_out" ]]; then
        problem "Lua that does not parse:"
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
            problem "lazy.lua imports nothing-directories:$empty"
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
        problem "require() targets that do not exist:$missing"
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
            problem "shared file(s) drifted from $BASE:$drifted"
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
        problem "config referencing absent plugins:$(echo "$dangling" | tr '|' ' ')"
    else
        ok "no config referencing absent plugins"
    fi

    # docs describing plugins this tier removed
    #
    # commands.md names the plugin as `owner/repo` in its Source column, so a
    # hit there is exact and counts as a failure. keymaps.md only names the
    # plugin in some of its tables, so a hit is reported but a miss proves
    # nothing and it stays advisory.
    if [[ "$b" != "$BASE" ]]; then
        stale_cmd="" stale_keys=""
        while read -r spec; do
            [[ -z "$spec" ]] && continue
            [[ -f "$d/$spec" ]] && continue
            repo=$(git show "$BASE:$spec" | grep -oP '^\s*"\K[^"]+/[^"]+' | head -1 || true)
            [[ -z "$repo" ]] && continue

            if [[ -f "$d/doc/commands.md" ]] && grep -qF -- "$repo" "$d/doc/commands.md"; then
                stale_cmd="$stale_cmd ${repo##*/}"
            fi
            if [[ -f "$d/doc/keymaps.md" ]] && grep -qE "\|[[:space:]]*($repo|${repo##*/})[[:space:]]*\|" \
                   "$d/doc/keymaps.md"; then
                stale_keys="$stale_keys ${repo##*/}"
            fi
        done < <(git ls-tree -r --name-only "$BASE" -- lua/plugins)

        if [[ -n "$stale_cmd" ]]; then
            problem "doc/commands.md documents removed plugin(s):$stale_cmd"
        else
            ok "commands.md documents nothing removed"
        fi
        if [[ -n "$stale_keys" ]]; then
            soft "doc/keymaps.md still mentions removed plugin(s):$stale_keys"
        else
            ok "keymaps.md mentions nothing removed"
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
            problem "$small has specs $large lacks: $(echo "$extra" | tr '\n' ' ')"
        else
            ok "$small ⊆ $large"
        fi
    done
fi

printf '\n'
passed_note="" failed_note=""
if [[ $WARNINGS -gt 0 ]]; then
    passed_note=" ($WARNINGS warning(s))"
    failed_note=", $WARNINGS warning(s)"
fi

if [[ $PROBLEMS -eq 0 ]]; then
    info "All checks passed$passed_note"
    exit 0
fi
die "$PROBLEMS problem(s) found$failed_note"
