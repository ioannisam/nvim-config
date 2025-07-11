return {
    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = {
            dir = vim.fn.stdpath("state") .. "/sessions/", -- directory to save sessions
            options = { "buffers", "curdir", "tabpages", "winsize" },
            need = 1,
            pre_save = nil,
        },
        keys = {
            {
                "<leader>pc",
                function() require("persistence").load() end,
                desc = "Restore Session"
            },
            {
                "<leader>pl",
                function() require("persistence").load({ last = true }) end,
                desc = "Restore Last Session"
            },
            {
                "<leader>pd",
                function() require("persistence").stop() end,
                desc = "Disable Persistence"
            },
        },
    }
}
