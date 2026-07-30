return {
    "chentoast/marks.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        default_mappings = true,
        builtin_marks = { ".", "<", ">", "^" },
        cyclic = true,
        force_write_shada = false,
        refresh_interval = 250,
        sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
        excluded_filetypes = {
            "alpha",
            "lazy",
            "neo-tree",
            "TelescopePrompt",
            "spectre_panel",
            "toggleterm",
            "undotree",
            "aerial",
            "typr",
        },
        excluded_buftypes = { "nofile", "quickfix", "terminal" },
    },
    keys = {
        { "<leader>xm", "<cmd>MarksQFListBuf<cr>", desc = "Marks quickfix (buffer)" },
        { "<leader>xM", "<cmd>MarksQFListGlobal<cr>", desc = "Marks quickfix (global)" },
    },
}
