return {
    "lewis6991/satellite.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        current_only = false,
        winblend = 50,
        zindex = 40,
        width = 2,
        excluded_filetypes = require("utils.filetypes").with(),
        handlers = {
            cursor = { enable = true },
            search = { enable = true },
            diagnostic = {
                enable = true,
                signs = { "-", "=", "≡" },
                min_severity = vim.diagnostic.severity.HINT,
            },
            gitsigns = {
                enable = true,
                signs = { add = "│", change = "│", delete = "-" },
            },
            marks = { enable = true, show_builtins = false },
            quickfix = { enable = true, signs = { "-", "=", "≡" } },
        },
    },
}
