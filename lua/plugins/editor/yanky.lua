return {
    "gbprod/yanky.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
        ring = {
            history_length = 100,
            storage = "shada",
            sync_with_numbered_registers = true,
            cancel_event = "update",
            ignore_registers = { "_" },
        },
        system_clipboard = {
            sync_with_ring = true,
        },
        highlight = {
            on_put = true,
            on_yank = true,
            timer = 200,
        },
        preserve_cursor_position = {
            enabled = true,
        },
    },
    config = function(_, opts)
        require("yanky").setup(opts)
        require("telescope").load_extension("yank_history")
    end,
    keys = {
        { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yanky: Yank" },
        { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Yanky: Put after" },
        { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Yanky: Put before" },
        { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Yanky: Put after (cursor at end)" },
        { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Yanky: Put before (cursor at end)" },
        { "<C-n>", "<Plug>(YankyNextEntry)", desc = "Yanky: Next yank entry" },
        { "<C-p>", "<Plug>(YankyPreviousEntry)", desc = "Yanky: Previous yank entry" },
        {
            "<leader>yh",
            "<cmd>Telescope yank_history<cr>",
            desc = "Yank history",
        },
        {
            "<leader>yc",
            function()
                require("yanky.history").clear()
                vim.notify("Cleared yank history", vim.log.levels.INFO, { title = "Yanky 󰅇" })
            end,
            desc = "Clear yank history",
        },
    },
}
