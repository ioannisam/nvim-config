-- this is a comment what difference does it make?

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
                -- fill integrations as you add plugins
            },
        })
        vim.cmd.colorscheme "catppuccin"
    end
}
