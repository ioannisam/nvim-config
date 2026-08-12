return {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        enable = true,
        multiwindow = false,
        max_lines = 3,
        min_window_height = 20,
        line_numbers = true,
        multiline_threshold = 1,
        trim_scope = "outer",
        mode = "cursor",
        separator = "─",
        zindex = 20,
    },
    config = function(_, opts)
        require("treesitter-context").setup(opts)

        vim.keymap.set("n", "[c", function()
            if vim.wo.diff then
                return "[c"
            end
            local count = vim.v.count1
            vim.schedule(function()
                require("treesitter-context").go_to_context(count)
            end)
            return "<Ignore>"
        end, { expr = true, silent = true, desc = "Treesitter: Jump to context" })
    end,
}
