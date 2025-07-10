return {
	"matze/vim-move",
	event = "VeryLazy",
	config = function()
        -- Remeber to remap the deafaults in other keys later

        -- Normal Mode
        vim.keymap.set("n", "J", "<Plug>MoveLineDown", {})
        vim.keymap.set("n", "K", "<Plug>MoveLineUp", {})

        -- Visual Mode
        vim.keymap.set("v", "J", "<Plug>MoveBlockDown", {})
        vim.keymap.set("v", "K", "<Plug>MoveBlockUp", {})
	end,
}
