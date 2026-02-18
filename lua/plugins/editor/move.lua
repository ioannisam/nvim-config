return {
    "matze/vim-move",
    event = "VeryLazy",
    init = function()
        vim.g.move_map_keys = 0
    end,
    config = function()
        -- Normal Mode
        vim.keymap.set("n", "J", "<Plug>MoveLineDown", { desc = "Move: Line down" })
        vim.keymap.set("n", "K", "<Plug>MoveLineUp", { desc = "Move: Line up" })

        -- Visual Mode
        vim.keymap.set("v", "J", "<Plug>MoveBlockDown", { desc = "Move: Selection down" })
        vim.keymap.set("v", "K", "<Plug>MoveBlockUp", { desc = "Move: Selection up" })
    end,
}
