return {
    "folke/trouble.nvim",
    dependencies = { "rcarriga/nvim-notify" },
    opts = {
        height = 10,
        position = "bottom",
    },
    lazy = false,
    cmd = "Trouble",
    keys = {
        {
            "<leader>xD",
            function()
                local special_windows = require("utils.special_windows")
                if not special_windows.is_open("trouble") then
                    special_windows.prepare_for_open("trouble")
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
                end
                vim.cmd("Trouble symbols toggle focus=false")
            end,
            desc = "Symbols (Trouble)",
        },
    },
}
