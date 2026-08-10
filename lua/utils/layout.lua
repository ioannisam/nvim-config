-- lua/utils/layout.lua
local M = {}

local function tab_wins()
    return vim.api.nvim_tabpage_list_wins(0)
end

local function win_buf(win)
    if not vim.api.nvim_win_is_valid(win) then
        return nil
    end
    local buf = vim.api.nvim_win_get_buf(win)
    if not vim.api.nvim_buf_is_valid(buf) then
        return nil
    end
    return buf
end

local function is_floating(win)
    local ok, cfg = pcall(vim.api.nvim_win_get_config, win)
    return ok and cfg and cfg.relative and cfg.relative ~= ""
end

-- Return Neo-tree window id (if any) in current tab
function M.get_neotree_win()
    for _, win in ipairs(tab_wins()) do
        local buf = win_buf(win)
        if buf and vim.bo[buf].filetype == "neo-tree" then
            return win
        end
    end
    return nil
end

-- Return a list of horizontal ToggleTerm windows (including native terminals you mark with b:native_term)
function M.get_toggleterm_wins()
    local wins = {}
    for _, win in ipairs(tab_wins()) do
        local buf = win_buf(win)
        if buf and not is_floating(win) then
            local bt = vim.bo[buf].buftype
            local is_toggleterm = vim.b[buf].is_toggleterm == true
            local dir = vim.b[buf].toggleterm_direction
            local is_native = vim.b[buf].native_term == true

            if (is_toggleterm and dir == "horizontal") or (is_native and bt == "terminal") then
                table.insert(wins, win)
            end
        end
    end
    return wins
end

local function is_terminal_win(win)
    local buf = win_buf(win)
    if not buf then
        return false
    end
    return vim.b[buf].is_toggleterm == true
        or (vim.b[buf].native_term == true and vim.bo[buf].buftype == "terminal")
end

-- Return the best editor window in current tab (largest width).
function M.get_main_win()
    local best = nil
    local best_w = -1
    for _, win in ipairs(tab_wins()) do
        local buf = win_buf(win)
        if buf and not is_floating(win) and vim.bo[buf].buftype == "" then
            local w = vim.api.nvim_win_get_width(win)
            if w > best_w then
                best_w = w
                best = win
            end
        end
    end
    return best
end

-- Move a full-width window into the main editor column, so it stops spanning underneath the side panels.
function M.confine_to_main(win)
    if not win or not vim.api.nvim_win_is_valid(win) then
        return
    end

    local main = M.get_main_win()
    if not main or not vim.api.nvim_win_is_valid(main) or win == main then
        return
    end

    if
        vim.api.nvim_win_get_width(main) < vim.o.columns
        and vim.api.nvim_win_get_width(win) >= vim.o.columns
    then
        pcall(vim.fn.win_splitmove, win, main, { vertical = false, rightbelow = true })
    end
end

function M.confine_terminals_to_main()
    for _, win in ipairs(M.get_toggleterm_wins()) do
        M.confine_to_main(win)
    end
end

-- Reflow: keep Neo-tree width and distribute remaining cols to terminal windows
function M.reflow_layout()
    local neotree_win = M.get_neotree_win()
    local term_wins = M.get_toggleterm_wins()
    local term_count = #term_wins

    local total_cols = vim.o.columns or 80
    local neotree_width = 0
    if neotree_win and vim.api.nvim_win_is_valid(neotree_win) then
        local ok, w = pcall(vim.api.nvim_win_get_width, neotree_win)
        if ok and type(w) == "number" then neotree_width = w end
    end

    local separator = neotree_width > 0 and 1 or 0
    local remaining_cols = math.max(total_cols - neotree_width - separator, 1)

    if term_count > 0 then
        local main_win = M.get_main_win()
        local avail = remaining_cols
        if main_win and vim.api.nvim_win_is_valid(main_win) then
            avail = vim.api.nvim_win_get_width(main_win)
        end

        local each_width = math.floor(avail / term_count)
        for _, win in ipairs(term_wins) do
            if vim.api.nvim_win_is_valid(win) then
                pcall(vim.api.nvim_win_set_width, win, math.max(1, each_width))
            end
        end
    end
end

function M.defer_reflow(delay)
    vim.defer_fn(M.reflow_layout, delay or 30)
end

function M.refresh_neotree_buffers()
    if not M.get_neotree_win() then
        return
    end
    vim.schedule(function()
        local ok, manager = pcall(require, "neo-tree.sources.manager")
        if ok then
            pcall(manager.refresh, "buffers")
        end
    end)
end

return M
