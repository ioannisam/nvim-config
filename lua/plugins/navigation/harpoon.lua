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
                            display = string.format("%s %s", icon or "", name),
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
                        local chosen = require("utils.picker").resolve_selection(prompt_bufnr, {
                            identity = function(entry)
                                return entry.value
                            end,
                        })

                        actions.close(prompt_bufnr)

                        for _, entry in ipairs(chosen) do
                            vim.cmd("edit " .. vim.fn.fnameescape(entry.value))
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

            require("utils.picker").multiselect(items, {
                prompt = "Select harpoons to delete:",
                format_item = function(x)
                    return string.format("[%d] %s", x.idx, x.path)
                end,
            }, function(selected)
                table.sort(selected, function(a, b)
                    return a.idx > b.idx
                end)
                for _, choice in ipairs(selected) do
                    list:remove_at(choice.idx)
                    vim.notify("Deleted harpoon " .. choice.idx, vim.log.levels.INFO, { title = "Harpoon 󰛢" })
                end
            end)
        end, { desc = "Delete Harpoon marks", noremap = true, silent = true })
    end,
}
