return {
    "lukas-reineke/indent-blankline.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    main = "ibl",
    event = "VeryLazy",
    config = function()
        local hooks = require("ibl.hooks")

        hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
            vim.api.nvim_set_hl(0, "IblIndent", { fg = "#575268", nocombine = true })
            vim.api.nvim_set_hl(0, "IblScope",  { fg = "#8aadf4", nocombine = true })
        end)

        require("ibl").setup({
            indent = { char = "│", highlight = "IblIndent" },
            scope  = {
                enabled    = true,
                show_start = false,
                show_end   = false,
                highlight  = "IblScope",
            },
            whitespace = {
                remove_blankline_trail = true,
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
