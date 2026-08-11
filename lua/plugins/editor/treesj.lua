return {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = { "tt", "tj", "ts" },
    config = function()
        require("treesj").setup({
            use_default_keymaps = false,
            check_syntax_error = false,
            cursor_behavior = "hold",
            notify = false,
            dot_repeat = false,
        })

        local tsj = require("treesj")
        vim.keymap.set("n", "tt", tsj.toggle, { desc = "TreeSJ Toggle" })
        vim.keymap.set("n", "tj", tsj.join, { desc = "TreeSJ Join" })
        vim.keymap.set("n", "ts", tsj.split, { desc = "TreeSJ Split" })
    end,
}
