return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"nvim-telescope/telescope.nvim",
		"rcarriga/nvim-notify",
	},
	config = function()
		local harpoon = require("harpoon")

		harpoon:setup({
			settings = {
				save_on_toggle = true,
				sync_on_ui_close = true,
				key = function()
					return vim.uv.cwd()
				end,
			},
		})

		vim.keymap.set("n", "<leader>ha", function()
			harpoon:list():add()
			vim.notify("Harpooned file", vim.log.levels.INFO, { title = "Harpoon 󰛢" })
		end, { desc = "Harpoon Add File" })
		vim.keymap.set("n", "<leader>hc", function()
			harpoon:list():clear()
            vim.notify("Cleared all harpoons", vim.log.levels.INFO, { title = "Harpoon 󰛢" })
		end, { desc = "Clear all Harpoon marks" })

        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        vim.keymap.set("n", "<leader>hm", function()
            local list = harpoon:list()

            if #list.items == 0 then
                vim.notify("No harpooned files", vim.log.levels.INFO, { title = "Harpoon 󰛢" })
                return
            end

            pickers.new({}, {
                prompt_title = "󰛢 Harpooned Files",
                finder = finders.new_table({
                    results = list.items,
                    entry_maker = function(entry)
                        local name = vim.fn.fnamemodify(entry.value, ":t")
                        local icon = require("nvim-web-devicons").get_icon(name, nil, { default = true })
                        return {
                            value = entry.value,
                            display = string.format("%s %s", icon or "", name),
                            ordinal = name,
                            filename = entry.value,
                        }
                    end,
                }),
                sorter = conf.file_sorter({}),
                previewer = conf.file_previewer({}),
                attach_mappings = function(prompt_bufnr, map)
                    map("i", "<Tab>", actions.toggle_selection + actions.move_selection_next)
                    map("i", "<S-Tab>", actions.toggle_selection + actions.move_selection_previous)
                    map("n", "<Tab>", actions.toggle_selection + actions.move_selection_next)
                    map("n", "<S-Tab>", actions.toggle_selection + actions.move_selection_previous)

                    actions.select_default:replace(function()
                        local picker = action_state.get_current_picker(prompt_bufnr)
                        local selections = picker:get_multi_selection()
                        local current_entry = action_state.get_selected_entry()

                        actions.close(prompt_bufnr)

                        if #selections == 0 and not current_entry then
                            return
                        end

                        local selected_files = {}
                        if #selections > 0 then
                            local found = false
                            for _, entry in ipairs(selections) do
                                table.insert(selected_files, entry.value)
                                if current_entry and entry.value == current_entry.value then
                                    found = true
                                end
                            end
                            if not found and current_entry then
                                table.insert(selected_files, current_entry.value)
                            end
                        else
                            table.insert(selected_files, current_entry.value)
                        end

                        for _, file in ipairs(selected_files) do
                            vim.cmd("edit " .. vim.fn.fnameescape(file))
                        end
                    end)

                    return true
                end,
            }):find()
        end, { desc = "Harpoon Menu" })

        vim.keymap.set("n", "<leader>hd", function()
            local list = harpoon:list()
            local marks = list.items

            if #marks == 0 then
                vim.notify("No harpoons to delete", vim.log.levels.INFO, { title = "Harpoon 󰛢" })
                return
            end

            local items = {}
            for i, item in ipairs(marks) do
                table.insert(items, {
                    idx = i,
                    path = item.value,
                    name = vim.fn.fnamemodify(item.value, ":t"),
                })
            end

            vim.ui.select(items, {
                prompt = "Delete harpoon:",
                format_item = function(x)
                    return string.format("[%d] %s", x.idx, x.path)
                end,
            }, function(choice)
                    if not choice then
                        return
                    end
                    list:remove_at(choice.idx)
                    vim.notify("Deleted harpoon " .. choice.idx, vim.log.levels.INFO, { title = "Harpoon 󰛢" })
                end)
        end, { desc = "Delete a Harpoon mark", noremap = true, silent = true })
    end,
}
