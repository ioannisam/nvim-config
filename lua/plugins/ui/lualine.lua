return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    event = "BufReadPre",
    config = function()
        require("lualine").setup({
            options = {
                theme = "auto",
                icons_enabled = true,
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = { "neo-tree", "lazy" },
            },
            sections = {
                lualine_a = { "mode" },
                -- No harpoon, gitsigns or LSP on this tier.
                lualine_b = { "branch" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
            extensions = { "neo-tree", "toggleterm", "lazy" },
        })
    end,
}
