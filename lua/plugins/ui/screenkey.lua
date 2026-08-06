return {
    "NStefan002/screenkey.nvim",
    version = "*",
    cmd = "Screenkey",
    opts = function()
        return {
            win_opts = {
                row = vim.o.lines - vim.o.cmdheight - 1,
                col = vim.o.columns - 1,
                relative = "editor",
                anchor = "SE",
                width = 40,
                height = 3,
                border = "rounded",
                title = "Screenkey",
                title_pos = "center",
                style = "minimal",
                focusable = false,
                noautocmd = true,
            },
            compress_after = 3,
            clear_after = 3,
            disable = {
                filetypes = { "alpha", "lazy", "neo-tree", "TelescopePrompt", "typr" },
                buftypes = {},
                events = false,
            },
            show_leader = true,
            group_mappings = false,
            display_infront = {},
            display_behind = {},
        }
    end,
    keys = {
        { "<leader>k", "<cmd>Screenkey toggle<cr>", desc = "Toggle Screenkey" },
    },
}
