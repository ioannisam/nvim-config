return {
    "lukas-reineke/indent-blankline.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    main = "ibl",
    event = "VeryLazy",
    config = function()
        require("ibl").setup({
            indent = {
                char = "│",
            },
            whitespace = {
                remove_blankline_trail = true,
            },
            scope = {
                enabled = true,
                show_start = false,
                show_end = false,
                include = {
                    node_type = { "function", "if_statement", "for_statement", "while_statement", "class", "block" },
                },
            },
            exclude = {
                filetypes = {
                    "help", "terminal", "toggleterm", "dashboard", "lazy", "NvimTree",
                    "Trouble", "alpha", "neo-tree", "Outline"
                },
                buftypes = { "terminal", "nofile" },
            },
        })
    end
}
