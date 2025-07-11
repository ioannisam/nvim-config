return {
    "OXY2DEV/markview.nvim",
    ft = { "markdown", "latex", "yaml" },
    config = function()
        require("markview").setup({
            auto_start = false,
            theme = "dark",
            open_cmd = nil,
            preview = {
                enable = false,
                filetypes = { "markdown", "latex", "yaml" },
            },
        })

        vim.api.nvim_set_keymap("n", "<leader>mp", ":Markview Toggle<CR>", { noremap = true, silent = true, desc = "Toggle Markdown Preview" })
    end,
}
