return {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialOpen", "AerialClose", "AerialNext", "AerialPrev" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        backends = { "lsp", "treesitter", "markdown", "man" },
        layout = {
            default_direction = "right",
            placement = "edge",
            min_width = 30,
            max_width = { 40, 0.2 },
            resize_to_content = false,
        },
        attach_mode = "global",
        close_automatic_events = {},
        show_guides = true,
        filter_kind = {
            "Class",
            "Constructor",
            "Enum",
            "Function",
            "Interface",
            "Module",
            "Method",
            "Struct",
        },
        -- Track the source cursor in the outline as you move/scroll.
        highlight_mode = "last",
        highlight_closest = true,
        highlight_on_hover = true,
        -- Moving the cursor in the outline scrolls the source window to that
        -- symbol. `select({ jump = false })` under the hood, so focus stays in
        -- the outline; <CR> is still what actually jumps you into the buffer.
        autojump = true,
        keymaps = {
            ["q"] = "actions.close",
            ["<CR>"] = "actions.jump",
            ["<2-LeftMouse>"] = "actions.jump",
            ["p"] = "actions.scroll",
            ["{"] = "actions.prev",
            ["}"] = "actions.next",
            ["C"] = "actions.tree_close_all",
            ["X"] = "actions.tree_open_all",
            ["?"] = "actions.show_help",
        },
    },
    keys = {
        { "<leader>o", "<cmd>AerialToggle!<cr>", desc = "Toggle Outline (Aerial)" },
    },
}
