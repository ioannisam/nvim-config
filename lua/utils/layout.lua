-- lua/utils/layout.lua
local M = {}

local function tab_wins()
    return vim.api.nvim_tabpage_list_wins(0)
end

-- Return Neo-tree window id (if any) in current tab
function M.get_neotree_win()
    for _, win in ipairs(tab_wins()) do
        if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            local ok, ft = pcall(vim.api.nvim_buf_get_option, buf, "filetype")
            if ok and ft == "neo-tree" then
                return win
            end
        end
    end
    return nil
end

-- Return a list of horizontal ToggleTerm windows (including native terminals you mark with b:native_term)
function M.get_toggleterm_wins()
    local wins = {}
    for _, win in ipairs(tab_wins()) do
        if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            local ok_ft, ft = pcall(vim.api.nvim_buf_get_option, buf, "filetype")
            local ok_bt, bt = pcall(vim.api.nvim_buf_get_option, buf, "buftype")

            local is_toggleterm = false
            pcall(function() is_toggleterm = vim.b[buf].is_toggleterm == true end)
            local dir = nil
            pcall(function() dir = vim.b[buf].toggleterm_direction end)
            local is_native = false
            pcall(function() is_native = vim.b[buf].native_term == true end)

            -- skip floating windows
            local ok_cfg, cfg = pcall(vim.api.nvim_win_get_config, win)
            if ok_cfg and cfg and cfg.relative and cfg.relative ~= "" then goto continue end

            if (is_toggleterm and dir == "horizontal") or (is_native and bt == "terminal") then
                table.insert(wins, win)
            end
        end
        ::continue::
    end
    return wins
end

-- Return the best non-Neo-tree editor window in current tab (largest width).
-- This is used as the "main" editor column to host terminals.
function M.get_main_win()
    local neotree_win = M.get_neotree_win()
    local best = nil
    local best_w = -1
    for _, win in ipairs(tab_wins()) do
        if vim.api.nvim_win_is_valid(win) and win ~= neotree_win then
            local buf = vim.api.nvim_win_get_buf(win)
            local ok_cfg, cfg = pcall(vim.api.nvim_win_get_config, win)
            if ok_cfg and cfg and cfg.relative and cfg.relative ~= "" then goto cont end
            local ok_ft, ft = pcall(vim.api.nvim_buf_get_option, buf, "filetype")
            if ok_ft and ft == "neo-tree" then goto cont end

            local w = vim.api.nvim_win_get_width(win)
            if w > best_w then
                best_w = w
                best = win
            end
        end
        ::cont::
    end
    return best
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

    local remaining_cols = math.max(total_cols - neotree_width, 1)

    if term_count > 0 then
        -- Explicitly resize the main editor column only when terminals are present,
        -- so side panels (Copilot Chat, etc.) are not squeezed by unrelated reflows.
        local main_win = M.get_main_win()
        if main_win and vim.api.nvim_win_is_valid(main_win) then
            pcall(vim.api.nvim_win_set_width, main_win, remaining_cols)
        end

        local each_width = math.floor(remaining_cols / term_count)
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

function M.reflow_neotree()
    local neotree_win = M.get_neotree_win()
    if not neotree_win or not vim.api.nvim_win_is_valid(neotree_win) then
        return
    end

    -- Remember current win to restore focus
    local current_win = vim.api.nvim_get_current_win()

    -- Toggle twice to force Neo-tree to reflow its layout
    vim.cmd("Neotree toggle")
    vim.cmd("Neotree toggle")

    -- Restore focus after Neo-tree redraws
    vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(current_win) then
            vim.api.nvim_set_current_win(current_win)
        end
    end, 30)
end

return M
