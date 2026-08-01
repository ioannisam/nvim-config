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
            -- No LSP or gitsigns on this tier, so both handlers have no source.
            diagnostic = { enable = false },
            gitsigns = { enable = false },
            marks = { enable = true, show_builtins = false },
            quickfix = { enable = true, signs = { "-", "=", "≡" } },
        },
    },
}
