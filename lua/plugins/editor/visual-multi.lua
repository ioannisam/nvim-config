return {
	{
		"mg979/vim-visual-multi",
		event = "VeryLazy",
		init = function()
			vim.g.VM_default_mappings = 0
			vim.g.VM_mouse_mappings = 0
			vim.g.VM_maps = {
				["Find Subword Under"] = "m",

                ["Find Next"] = "n",
				["Find Prev"] = "p",
                ["Skip Region"] = "s",

				["Add Cursor Up"] = "j",
				["Add Cursor Down"] = "k",
				["Remove Region"] = "q",
			}
		end,
	},
}
