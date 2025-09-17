return {
    "matze/vim-move",
    event = "VeryLazy",
    init = function()
        vim.g.move_map_keys = 0
    end,
    config = function()
        -- Normal Mode
        vim.keymap.set("n", "J", "<Plug>MoveLineDown", {})
        vim.keymap.set("n", "K", "<Plug>MoveLineUp", {})

        -- Visual Mode
        vim.keymap.set("v", "J", "<Plug>MoveBlockDown", {})
        vim.keymap.set("v", "K", "<Plug>MoveBlockUp", {})
    end,
}
