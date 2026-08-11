return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
    },

    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        local function entry_file(entry)
            return entry and (entry.filename or entry.value) or nil
        end

        local function open_selected_or_current(prompt_bufnr)
            local chosen = require("utils.picker").resolve_selection(prompt_bufnr, {
                identity = entry_file,
                allow = function(entry)
                    return entry_file(entry) ~= nil
                end,
            })

            actions.close(prompt_bufnr)

            for _, entry in ipairs(chosen) do
                vim.cmd("edit " .. vim.fn.fnameescape(entry_file(entry)))
                if entry.lnum then
                    local col = math.max((entry.col or 1) - 1, 0)
                    pcall(vim.api.nvim_win_set_cursor, 0, { entry.lnum, col })
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
