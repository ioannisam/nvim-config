local filetypes = require("utils.filetypes")

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

M.is_floating = is_floating

function M.is_panel(buf, win)
    if not buf or not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
        return true, "invalid"
    end

    if win and vim.api.nvim_win_is_valid(win) then
        if is_floating(win) then
            return true, "floating window"
        end
        local wtype = vim.fn.win_gettype(win)
        if wtype ~= "" and wtype ~= "normal" then
            return true, "special window type"
        end
    end

    local buftype = vim.bo[buf].buftype
    if buftype ~= "" and not (buftype == "terminal" and vim.b[buf].native_term) then
        return true, "special buftype"
    end

    local filetype = vim.bo[buf].filetype
    if filetypes.contains(filetype) then
        return true, "excluded filetype: " .. filetype
    end

    if vim.b[buf].bufferline_exclude then
        return true, "explicitly excluded"
    end

    return false
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

-- Return the main editor window in current tab (largest non-panel window).
function M.get_main_win()
    local best, best_area = nil, -1
    for _, win in ipairs(tab_wins()) do
        local buf = win_buf(win)
        if buf and not M.is_panel(buf, win) then
            local area = vim.api.nvim_win_get_width(win) * vim.api.nvim_win_get_height(win)
            if area > best_area then
                best_area = area
                best = win
            end
        end
    end
    return best
end

-- Move the cursor into the main editor window, unless it is already in one.
function M.focus_main_win(opts)
    opts = opts or {}

    local cur = vim.api.nvim_get_current_win()
    if not M.is_panel(win_buf(cur), cur) then
        return true
    end

    local best = M.get_main_win()
    if best and vim.api.nvim_win_is_valid(best) then
        vim.api.nvim_set_current_win(best)
        return true
    end

    if not opts.silent then
        vim.notify("No main editor window available", vim.log.levels.WARN, { title = opts.title or "Layout" })
    end
    return false
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
        local height = vim.api.nvim_win_get_height(win)
        if pcall(vim.fn.win_splitmove, win, main, { vertical = false, rightbelow = true }) then
            pcall(vim.api.nvim_win_set_height, win, height)
        end
    end
end

function M.confine_terminals_to_main()
    for _, win in ipairs(M.get_toggleterm_wins()) do
        M.confine_to_main(win)
    end
end

-- Reflow: toggleterm lays multiple horizontal terminals side by side in a strip
-- under the main window, so they share that strip's width. The main window is
-- left out: a native terminal that took over the editor window is not a bottom
-- panel and keeps its size.
function M.reflow_layout()
    local main = M.get_main_win()

    local panels = {}
    for _, win in ipairs(M.get_toggleterm_wins()) do
        if vim.api.nvim_win_is_valid(win) and win ~= main then
            table.insert(panels, win)
        end
    end

    local count = #panels
    if count == 0 then
        return
    end

    local avail = vim.o.columns or 80
    if main and vim.api.nvim_win_is_valid(main) then
        avail = vim.api.nvim_win_get_width(main)
    else
        local neotree_win = M.get_neotree_win()
        if neotree_win and vim.api.nvim_win_is_valid(neotree_win) then
            local ok, w = pcall(vim.api.nvim_win_get_width, neotree_win)
            if ok and type(w) == "number" then
                avail = math.max(avail - w - 1, 1)
            end
        end
    end

    local each_width = math.floor((avail - (count - 1)) / count)
    if each_width < 1 then
        return
    end

    for _, win in ipairs(panels) do
        pcall(vim.api.nvim_win_set_width, win, each_width)
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
