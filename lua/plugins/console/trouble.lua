return {
    "folke/trouble.nvim",
    dependencies = { "rcarriga/nvim-notify" },
    opts = {
        win = {
            position = "bottom",
            relative = "win",
            size = 10,
        },
    },
    cmd = "Trouble",
    keys = {
        {
            "<leader>xD",
            function()
                local special_windows = require("utils.special_windows")
                if not special_windows.is_open("trouble") then
                    special_windows.prepare_for_open("trouble")
                    local main = require("utils.layout").get_main_win()
                    if main and vim.api.nvim_win_is_valid(main) then
                        vim.api.nvim_set_current_win(main)
                    end
                end
                vim.cmd("Trouble diagnostics toggle focus=true")
            end,
            desc = "Diagnostics (Trouble)",
        },
        {
            "<leader>xd",
            function()
                local special_windows = require("utils.special_windows")
                if not special_windows.is_open("trouble") then
                    special_windows.prepare_for_open("trouble")
                    local main = require("utils.layout").get_main_win()
                    if main and vim.api.nvim_win_is_valid(main) then
                        vim.api.nvim_set_current_win(main)
                    end
                end
                vim.cmd("Trouble diagnostics toggle filter.buf=0 focus=true")
            end,
            desc = "Buffer Diagnostics (Trouble)",
        },
        {
            "<leader>xs",
            function()
                local special_windows = require("utils.special_windows")
                if not special_windows.is_open("trouble") then
                    special_windows.prepare_for_open("trouble")
                    local main = require("utils.layout").get_main_win()
                    if main and vim.api.nvim_win_is_valid(main) then
                        vim.api.nvim_set_current_win(main)
                    end
                end
                vim.cmd("Trouble symbols toggle focus=false")
            end,
            desc = "Symbols (Trouble)",
        },
    },
}
