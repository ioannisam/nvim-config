return {
    "mbbill/undotree",
    keys = {
        {
            "<leader>u",
            function()
                local special_windows = require("utils.special_windows")
                if special_windows.is_open("undotree") then
                    vim.cmd("UndotreeToggle")
                    return
                end
                special_windows.prepare_for_open("undotree")

                local saved = vim.o.lazyredraw
                vim.o.lazyredraw = true
                pcall(vim.cmd, "UndotreeToggle")
                vim.o.lazyredraw = saved
            end,
            desc = "Toggle UndoTree",
        },
    },
    config = function()
        vim.g.undotree_WindowLayout = 2
        vim.g.undotree_SplitWidth = 30
        vim.g.undotree_SetFocusWhenToggle = 1

        local function place_undotree_windows()
            local layout = require("utils.layout")
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                if vim.api.nvim_win_is_valid(win) then
                    local buf = vim.api.nvim_win_get_buf(win)
                    local name = vim.api.nvim_buf_is_valid(buf)
                        and vim.api.nvim_buf_get_name(buf)
                        or ""

                    if name:find("undotree_", 1, true) then
                        pcall(vim.api.nvim_set_option_value, "winfixwidth", true, { win = win })
                        pcall(vim.api.nvim_win_set_width, win, vim.g.undotree_SplitWidth or 30)
                    elseif name:find("diffpanel_", 1, true) then
                        pcall(vim.api.nvim_set_option_value, "winfixwidth", false, { win = win })
                        layout.confine_to_main(win)
                    end
                end
            end
        end

        vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinNew" }, {
            group = vim.api.nvim_create_augroup("undotree_layout", { clear = true }),
            callback = function()
                place_undotree_windows()
                vim.schedule(place_undotree_windows)
            end,
        })
    end,
}
