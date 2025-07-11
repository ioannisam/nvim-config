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
        telescope.setup({
            defaults = {
                sorting_strategy = "ascending",
                prompt_prefix = " ",
                selection_caret = "▶ ",
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
                    layout_strategy = "horizontal",
                    previewer = true,
                    hidden = false,
                    follow = false,
                    no_ignore = false,
                    no_ignore_parent = false,
                    search_dirs = nil,
                    find_command = nil,
                },
                live_grep = {
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
                    theme = "dropdown",
                    previewer = false,
                },
            },
        })

        telescope.load_extension("fzf")
        telescope.load_extension("harpoon")
        vim.keymap.set("n", "<leader>fm", function()
            require("telescope").extensions.harpoon.marks()
        end, { desc = "Find Harpoon Marks" })

        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
        vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
        vim.keymap.set(
            "n",
            "<leader>g",
            require("telescope.builtin").grep_string,
            { desc = "Grep String under Cursor" }
        )
    end,
}
