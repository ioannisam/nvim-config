return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            config = function()
                require("telescope").load_extension("fzf")
            end,
        },
    },

    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        local function open_selected_or_current(prompt_bufnr)
            local picker = action_state.get_current_picker(prompt_bufnr)
            local selections = picker:get_multi_selection()
            local current_entry = action_state.get_selected_entry()
            actions.close(prompt_bufnr)

            local selected_files = {}

            if not vim.tbl_isempty(selections) then
                local found = false
                for _, entry in ipairs(selections) do
                    local file = entry.filename or entry.value
                    table.insert(selected_files, { file = file, lnum = entry.lnum, col = entry.col })
                    if file == (current_entry.filename or current_entry.value) then
                        found = true
                    end
                end
                if not found then
                    local file = current_entry.filename or current_entry.value
                    table.insert(selected_files, { file = file, lnum = current_entry.lnum, col = current_entry.col })
                end
            else
                local file = current_entry.filename or current_entry.value
                table.insert(selected_files, { file = file, lnum = current_entry.lnum, col = current_entry.col })
            end

            for _, entry in ipairs(selected_files) do
                vim.cmd("edit " .. entry.file)
                if entry.lnum then
                    vim.api.nvim_win_set_cursor(0, { entry.lnum, entry.col or 0 })
                end
            end
        end

        telescope.setup({
            defaults = {
                preview = {
                    treesitter = false,
                },
                sorting_strategy = "ascending",
                prompt_prefix = " ",
                selection_caret = "▶ ",
                multi_icon = "✚ ",
                layout_config = {
                    horizontal = {
                        width = 0.9,
                        height = 0.9,
                        preview_width = 0.5,
                        prompt_position = "bottom",
                        mirror = false,
                    },
                    vertical = {
                        width = 0.5,
                        height = 0.8,
                        preview_width = 0.5,
                        prompt_position = "bottom",
                        mirror = false,
                    },
                },
                file_ignore_patterns = {
                    "%.git/",
                    "%.cache/",
                },
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<esc>"] = actions.close,
                        ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
                        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
                    },
                    n = {
                        ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
                        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
                    },
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                },
            },
            pickers = {
                find_files = {
                    prompt_title = " Find Files",
                    mappings = {
                        i = { ["<CR>"] = open_selected_or_current },
                        n = { ["<CR>"] = open_selected_or_current },
                    },
                    layout_strategy = "horizontal",
                    previewer = true,
                    hidden = false,
                    follow = false,
                    search_dirs = nil,
                    find_command = nil,
                },
                live_grep = {
                    prompt_title = " Live Grep",
                    mappings = {
                        i = { ["<CR>"] = open_selected_or_current },
                        n = { ["<CR>"] = open_selected_or_current },
                    },
                    layout_strategy = "horizontal",
                    previewer = true,
                    additional_args = nil,
                    glob_pattern = nil,
                    search_dirs = nil,
                    disable_coordinates = false,
                    use_regex = false,
                    only_cwd = false,
                },
                help_tags = {
                    prompt_title = "󰋖 Help Tags",
                    theme = "dropdown",
                    previewer = false,
                },
            },
        })

        telescope.load_extension("fzf")
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope: Find files" })
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope: Live grep" })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope: Help tags" })
        vim.keymap.set(
            "n",
            "<leader>fw",
            require("telescope.builtin").grep_string,
            { desc = "Telescope: Grep word under cursor" }
        )
    end,
}
