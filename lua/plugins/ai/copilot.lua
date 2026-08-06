return {
	{
		"zbirenbaum/copilot.lua",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true,
					keymap = {
						accept = "<M-a>",
						next = "<M-n>",
						prev = "<M-p>",
						dismiss = "<M-d>",
					},
				},
				panel = { enabled = false },
			})

			vim.api.nvim_create_user_command("CopilotAuth", function()
				require("copilot.auth").signin()
				vim.notify("Check Neovim :messages for auth link", vim.log.levels.INFO, { title = "Copilot " })
			end, {})
		end,
	},
}
