return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    config = function()

        local function relative_path(full_path)
            local cwd = vim.loop.cwd()
            if cwd and vim.startswith(full_path, cwd) then
                return full_path:sub(#cwd + 2)
            end

            return vim.fn.fnamemodify(full_path, ":~:.")
        end

        local function git_confirm(message, on_confirmed)
            local input = require("neo-tree.ui.inputs")
            input.confirm(message, function(confirmed)
                if confirmed then
                    on_confirmed()
                else
                    vim.notify("Canceled: " .. message, vim.log.levels.WARN)
                end
            end)
        end

        local last_neotree_source = "filesystem"
        local function toggle_last_neotree()
            local src = last_neotree_source or "filesystem"
            require("neo-tree.command").execute({ toggle = true, source = src })
        end

        require("neo-tree").setup({

            source_selector = {
                winbar = true,
                statusline = false,
            },

            default_component_configs = {
                indent = {
                    with_markers = true,
                    indent_marker = "│",
                    last_indent_marker = "└",
                    indent_size = 2,

                    with_expanders = true,
                    expander_collapsed = "",
                    expander_expanded = "",
                    expander_highlight = "NeoTreeExpander",
                },
                icon = {
                    folder_closed = "",
                    folder_open = "",
                    folder_empty = "",
                    default = "",
                },
                git_status = {
                    -- symbols = false
                    symbols = {
                        -- Change Type
                        added     = "✚",
                        deleted   = "✖",
                        modified  = "",
                        renamed   = "󰁕",
                        -- Status Type
                        untracked = "",
                        ignored   = "",
                        unstaged  = "󰄱",
                        staged    = "",
                        conflict  = "",
                    },
                },
            },

            use_default_mappings = false,
            close_if_last_window = true,
            sort_case_insensitive = true,
            sort_function = nil,
            window = {
                position = "left",
                width = 30,
                mapping_options = {
                    noremap = true,
                    nowait = true,
                },
                mappings = {
                    ["<2-leftmouse>"] = "open",
                    ["<cr>"] = "toggle_node",
                    ["<cr>"] = "open",
                    ["s"] = "open_vsplit",
                    ["S"] = "open_split",

                    ["q"] = "close_window",
                    [">"] = "next_source",
                    ["<"] = "prev_source",

                    ["C"] = "close_all_nodes",
                    ["X"] = "expand_all_nodes",

                    ["?"] = "show_help",
                },
            },

            popup_border_style = "rounded",
            enable_diagnostics = true,
            filesystem = {
                hijack_netrw_behavior = "open_default",
                follow_current_file = {
                    enabled = true,
                },
                group_empty_dirs = false,
                use_libuv_file_watcher = true,
                filtered_items = {
                    visible = false,
                    hide_dotfiles = true,
                    hide_gitignored = true,
                },
                preview = {
                    enabled = true,
                    reveal_on_cursor = true,
                    use_float = true,
                    float = {
                        max_width = 80,
                        max_height = 20,
                        border = "rounded",
                    },
                },
                window = {
                    mappings = {
                        ["<bs>"] = "navigate_up",
                        ["."] = "set_root",

                        ["H"] = "toggle_hidden",
                        ["R"] = "refresh",
                        ["P"] = { "toggle_preview", config = { use_float = true } },
                        ["F"] = "focus_preview",

                        ["a"] = "add",
                        ["m"] = "move",
                        ["r"] = "rename",
                        ["d"] = "delete",
                        ["c"] = "copy",
                        ["y"] = "copy_to_clipboard",
                        ["x"] = "cut_to_clipboard",
                        ["p"] = "paste_from_clipboard",

                        ["i"] = "show_file_details",
                        ["/"] = "filter_on_submit",
                        ["f"] = "fuzzy_finder",
                        ["<esc>"] = "clear_filter",

                        ["on"] = "order_by_name",
                        ["oc"] = "order_by_created",
                        ["om"] = "order_by_modified",
                        ["os"] = "order_by_size",
                        ["ot"] = "order_by_type",
                        ["od"] = "order_by_diagnostics",
                        ["og"] = "order_by_git_status",
                    },
                },
                commands = {},

            },

            buffers = {
                follow_current_file = {
                    enabled = true,
                },
                group_empty_dirs = false,
                show_unloaded = true,
                window = {
                    mappings = {
                        ["d"] = "buffer_delete",
                    },
                },
            },

            enable_git_status = true,
            git_status = {
                window = {
                    position = "float",
                    mappings = {
                        ["a"] = "git_add_file",
                        ["u"] = "git_unstage_file",
                        ["r"] = function(state)
                            local node = state.tree:get_node()
                            local path = node.path
                            git_confirm("Revert changes to: " .. relative_path(path) .. "?", function()
                                local out = vim.fn.system({ "git", "restore", "--", path })
                                if vim.v.shell_error == 0 then
                                    local bufnr = vim.fn.bufnr(path)
                                    if bufnr ~= -1 then
                                        pcall(vim.cmd, "silent checktime " .. bufnr)
                                    end
                                    vim.notify("File reverted: " .. relative_path(path), vim.log.levels.INFO)
                                else
                                    vim.notify("Git restore failed: " .. out, vim.log.levels.ERROR)
                                end
                                require("neo-tree.sources.git_status").refresh(state)
                            end)
                        end,
                        ["c"] = "git_commit",
                        ["p"] = "git_push",
                        ["g"] = "git_commit_and_push",

                        ["A"] = "git_add_all",
                        ["U"] = function(state)
                            vim.fn.system("git reset")
                            require("neo-tree.sources.git_status").refresh(state)
                        end,
                        ["R"] = function(state)
                            git_confirm("Revert ALL files?", function()
                                local out = vim.fn.system({ "git", "restore", "--", "." })
                                if vim.v.shell_error == 0 then
                                    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                                        local name = vim.api.nvim_buf_get_name(bufnr)
                                        if vim.api.nvim_buf_is_loaded(bufnr) and vim.fn.filereadable(name) == 1 then
                                            pcall(vim.cmd, "silent checktime " .. bufnr)
                                        end
                                    end
                                    vim.notify("All files reverted and buffers reloaded.", vim.log.levels.INFO)
                                else
                                    vim.notify("Git restore failed: " .. out, vim.log.levels.ERROR)
                                end
                                require("neo-tree.sources.git_status").refresh(state)
                            end)
                        end,
                    },
                },
            },

            event_handlers = {
                {
                    event = "neo_tree_window_after_open",
                    handler = function(args)
                        if type(args) == "table" and args.source then
                            last_neotree_source = args.source
                        end

                        local win = vim.api.nvim_get_current_win()
                        local buf = vim.api.nvim_win_get_buf(win)
                        local function clear_columns()
                            if not vim.api.nvim_win_is_valid(win) then return end
                            pcall(vim.api.nvim_win_set_option, win, "statuscolumn", "")
                            pcall(vim.api.nvim_win_set_option, win, "foldcolumn", "0")
                            pcall(vim.api.nvim_win_set_option, win, "signcolumn", "no")

                            local ok, gs = pcall(require, "gitsigns")
                            if ok then pcall(gs.detach, buf) end
                        end

                        vim.defer_fn(clear_columns, 20)
                    end,
                },
                {
                    event = "file_added",
                    handler = function(filepath)
                        vim.notify("File added: " .. relative_path(filepath), vim.log.levels.INFO)
                    end,
                },
                {
                    event = "file_deleted",
                    handler = function(filepath)
                        vim.notify("File deleted: " .. relative_path(filepath), vim.log.levels.WARN)
                    end,
                },
                {
                    event = "file_moved",
                    handler = function(info)
                        vim.notify("File moved: " .. relative_path(info.source) .. " → " .. relative_path(info.destination), vim.log.levels.INFO)
                    end,
                },
                {
                    event = "file_renamed",
                    handler = function(info)
                        vim.notify("File renamed: " .. relative_path(info.source) .. " → " .. relative_path(info.destination), vim.log.levels.INFO)
                    end,
                },
            }
        })

        vim.keymap.set('n', '<leader>n', toggle_last_neotree, { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>w', '<C-w>w', { noremap = true, silent = true })
        vim.diagnostic.config({
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = '',
                    [vim.diagnostic.severity.WARN] = '',
                    [vim.diagnostic.severity.INFO] = '',
                    [vim.diagnostic.severity.HINT] = '󰌵',
                },
            }
        })
    end
}
