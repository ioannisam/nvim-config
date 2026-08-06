local M = {}

local function tab_wins()
    return vim.api.nvim_tabpage_list_wins(0)
end

local function is_floating(win)
    local ok, cfg = pcall(vim.api.nvim_win_get_config, win)
    return ok and cfg and cfg.relative and cfg.relative ~= ""
end

local function get_win_kind(win)
    if not vim.api.nvim_win_is_valid(win) then
        return nil
    end

    local buf = vim.api.nvim_win_get_buf(win)
    if not vim.api.nvim_buf_is_valid(buf) then
        return nil
    end

    local ft = vim.bo[buf].filetype
    local bt = vim.bo[buf].buftype

    if ft == "neo-tree" then
        return "neotree"
    end

    if is_floating(win) then
        return nil
    end

    if vim.b[buf].is_toggleterm == true or (vim.b[buf].native_term == true and bt == "terminal") then
        return "toggleterm"
    end

    if bt == "quickfix" then
        local title = vim.fn.getqflist({ title = 1 }).title
        if title == "Notifications" then
            return "notifications"
        end
    end

    if ft == "spectre_panel" then
        return "spectre"
    end

    if ft == "undotree" or ft == "diff" then
        local name = vim.api.nvim_buf_get_name(buf)
        if name:find("undotree", 1, true) then
            return "undotree"
        end
    end

    if ft:find("trouble", 1, true) then
        return "trouble"
    end

    if ft:find("copilot", 1, true) and ft:find("chat", 1, true) then
        return "copilotchat"
    end

    return nil
end

function M.is_open(kind)
    for _, win in ipairs(tab_wins()) do
        if get_win_kind(win) == kind then
            return true
        end
    end
    return false
end

local function close_kind(kind)
    if kind == "undotree" then
        pcall(vim.cmd, "silent! UndotreeHide")
    elseif kind == "trouble" then
        pcall(vim.cmd, "silent! Trouble close")
    elseif kind == "copilotchat" then
        pcall(function()
            require("CopilotChat").close()
        end)
    end

    for _, win in ipairs(tab_wins()) do
        if get_win_kind(win) == kind and vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_win_close, win, true)
        end
    end

    if kind == "notifications" then
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_is_valid(win) then
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "notifydetails" then
                    pcall(vim.api.nvim_win_close, win, true)
                end
            end
        end
    end
end

local function should_close(kind, target_kind)
    if kind == target_kind then
        return false
    end

    if target_kind == "toggleterm" then
        return kind ~= "neotree"
    end

    if target_kind == "notifications" then
        return kind ~= "neotree"
    end

    if target_kind == "neotree" then
        return kind ~= "toggleterm" and kind ~= "notifications"
    end

    return true
end

function M.prepare_for_open(target_kind)
    if target_kind == "toggleterm" then
        close_kind("notifications")
    elseif target_kind == "notifications" then
        close_kind("toggleterm")
    end

    local present = {}
    for _, win in ipairs(tab_wins()) do
        local kind = get_win_kind(win)
        if kind then
            present[kind] = true
        end
    end

    if target_kind == "neotree" and present.toggleterm and present.notifications then
        close_kind("notifications")
        present.notifications = nil
    end

    for kind, _ in pairs(present) do
        if should_close(kind, target_kind) then
            close_kind(kind)
        end
    end
end

return M
