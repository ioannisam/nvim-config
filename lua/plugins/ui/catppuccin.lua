return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha", -- latte, frappe, macchiato, mocha
            dim_inactive = {
                enabled = true,
                shade = "dark",
                percentage = 0.00,
            },
            term_colors = true,
            default_integrations = true,
            integrations = {
                neotree = true,
                telescope = true,
                -- toggleterm = true,
                illuminate = true,
                -- lualine = true,
                alpha = true,
                beacon = false,
                mason = false,
                -- fill integrations as you add plugins
            },
        })
        vim.cmd.colorscheme "catppuccin"
    end
}
