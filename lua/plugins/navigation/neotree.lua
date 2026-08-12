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
            local cwd = vim.uv.cwd()
            if cwd then
                if not vim.endswith(cwd, "/") then
                    cwd = cwd .. "/"
                end
                if vim.startswith(full_path, cwd) then
                    return full_path:sub(#cwd + 1)
                end
            end

            return vim.fn.fnamemodify(full_path, ":~:.")
        end

        local function state_root(state)
            local dir = state and state.path
            if type(dir) == "string" and vim.fn.isdirectory(dir) == 1 then
                return dir
            end
            return vim.uv.cwd()
        end

        local function git_exec(state, cmd)
            local res = vim.system(cmd, { cwd = state_root(state), text = true }):wait()
            return res.code == 0, (res.stderr or "") .. (res.stdout or "")
        end

        local function git_confirm(message, on_confirmed)
            local input = require("neo-tree.ui.inputs")
            input.confirm(message, function(confirmed)
                if confirmed then
                    on_confirmed()
                else
                    vim.notify("Canceled: " .. message, vim.log.levels.WARN, {title = "Neo-tree 󰹩"})
                end
            end)
        end

        local function apply_neotree_orange_highlights()
            local orange = "#fab387"

            local ok_palette, palettes = pcall(require, "catppuccin.palettes")
            if ok_palette and palettes and type(palettes.get_palette) == "function" then
                local palette = palettes.get_palette(vim.g.catppuccin_flavour or "mocha")
                if palette then
                    orange = palette.peach or palette.yellow or orange
                end
            end

            vim.api.nvim_set_hl(0, "NeoTreeMultiSelectName", { fg = orange, bold = true })
        end

        local last_neotree_source = "filesystem"
        local function toggle_last_neotree()
            local src = last_neotree_source or "filesystem"
            require("utils.special_windows").open("neotree", function()
                require("neo-tree.command").execute({ toggle = true, source = src, position = "left" })
            end)
        end

        local get_multiselect_state
        local clear_multiselect
        local refresh_source

        local function get_selected_paths_or_current(state, options)
            local opts = options or {}
            local selected, _ = get_multiselect_state(state)
            local current = state.tree:get_node()

            local paths = {}
            for _, entry in ipairs(selected.order) do
                table.insert(paths, entry.path)
            end

            return require("utils.picker").union(paths, current and current.path or nil, {
                allow = opts.allow or function(path)
                    return type(path) == "string"
                end,
            })
        end

        local function buf_for_path(path)
            if type(path) ~= "string" or path == "" then
                return -1
            end
            local target = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(buf) then
                    local name = vim.api.nvim_buf_get_name(buf)
                    if name ~= "" and vim.fs.normalize(name) == target then
                        return buf
                    end
                end
            end
            return -1
        end

        local function safe_bdelete(bufnr)
            if type(bufnr) ~= "number" or bufnr < 1 then return end
            if not vim.api.nvim_buf_is_valid(bufnr) then return end

            local ok_bufdelete, bufdelete = pcall(require, "bufdelete")
            if ok_bufdelete and type(bufdelete.bufdelete) == "function" then
                pcall(bufdelete.bufdelete, bufnr, true)
                return
            end

            pcall(vim.cmd, "silent! bdelete! " .. bufnr)
        end

        local function has_real_file_buffers()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
                    local name = vim.api.nvim_buf_get_name(buf)
                    if name ~= "" and vim.bo[buf].buftype == "" then
                        return true
                    end
                end
            end
            return false
        end

        local function focus_editor_if_no_real_buffers()
            vim.schedule(function()
                if has_real_file_buffers() then return end

                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype ~= "neo-tree" then
                        pcall(vim.api.nvim_set_current_win, win)
                        break
                    end
                end

                local cur = vim.api.nvim_get_current_buf()
                if
                    vim.api.nvim_buf_is_valid(cur)
                    and vim.api.nvim_buf_get_name(cur) == ""
                    and not vim.bo[cur].modified
                    and vim.bo[cur].buftype == ""
                    and vim.bo[cur].filetype == ""
                then
                    pcall(vim.cmd, "bwipeout!")
                end
            end)
        end

        local function delete_buffer_entry(state, target_path)
            local path = target_path
            if not path then
                local node = state.tree:get_node()
                if not node then return end
                path = node.path
            end

            local bufnr = buf_for_path(path)
            if bufnr == -1 then return end

            safe_bdelete(bufnr)
        end

        local function delete_selected_buffers_or_current(state)
            local paths = get_selected_paths_or_current(state, {
                allow = function(path)
                    return type(path) == "string" and buf_for_path(path) ~= -1
                end,
            })

            if #paths == 0 then return end

            if #paths == 1 then
                delete_buffer_entry(state, paths[1])
                refresh_source(state, "buffers")
                clear_multiselect(state)
                focus_editor_if_no_real_buffers()
                return
            end

            for _, path in ipairs(paths) do
                delete_buffer_entry(state, path)
            end

            refresh_source(state, "buffers")
            clear_multiselect(state)
            focus_editor_if_no_real_buffers()
        end

        refresh_source = function(state, source)
            local ok, manager = pcall(require, "neo-tree.sources.manager")
            if ok then
                manager.refresh(source or state.name)
            end
        end

        local function run_git_on_selected_or_current(state, spec)
            local paths = get_selected_paths_or_current(state, {
                allow = function(path)
                    return type(path) == "string" and #path > 0
                end,
            })

            if #paths == 0 then
                refresh_source(state, "git_status")
                return
            end

            local failed = {}
            for _, path in ipairs(paths) do
                local ok, out = git_exec(state, spec.make_cmd(path))
                if not ok then
                    table.insert(failed, { path = path, out = out })
                end
            end

            if #failed == 0 then
                if type(spec.on_success) == "function" then
                    spec.on_success(paths)
                end
                clear_multiselect(state)
            else
                vim.notify(
                    (spec.fail_message or "Git command failed") .. ": " .. relative_path(failed[1].path),
                    vim.log.levels.ERROR,
                    { title = "Neo-tree 󰹩" }
                )
            end

            refresh_source(state, "git_status")
        end

        local function git_add_selected_or_current(state)
            run_git_on_selected_or_current(state, {
                make_cmd = function(path)
                    return { "git", "add", "--", path }
                end,
                on_success = function(paths)
                    vim.notify("Staged " .. tostring(#paths) .. " file(s)", vim.log.levels.INFO, { title = "Neo-tree 󰹩" })
                end,
                fail_message = "Git add failed",
            })
        end

        local function git_unstage_selected_or_current(state)
            run_git_on_selected_or_current(state, {
                make_cmd = function(path)
                    return { "git", "restore", "--staged", "--", path }
                end,
                on_success = function(paths)
                    vim.notify("Unstaged " .. tostring(#paths) .. " file(s)", vim.log.levels.INFO, { title = "Neo-tree 󰹩" })
                end,
                fail_message = "Git unstage failed",
            })
        end

        local function git_revert_selected_or_current(state)
            local paths = get_selected_paths_or_current(state, {
                allow = function(path)
                    return type(path) == "string" and #path > 0
                end,
            })
            if #paths == 0 then return end

            local message
            if #paths == 1 then
                message = "Revert changes to: " .. relative_path(paths[1]) .. "?"
            else
                message = "Revert changes to " .. tostring(#paths) .. " selected file(s)?"
            end

            git_confirm(message, function()
                local failed = {}
                for _, path in ipairs(paths) do
                    local ok, out = git_exec(state, { "git", "restore", "--", path })
                    if ok then
                        local bufnr = buf_for_path(path)
                        if bufnr ~= -1 then
                            pcall(vim.cmd, "silent checktime " .. bufnr)
                        end
                    else
                        table.insert(failed, { path = path, out = out })
                    end
                end

                if #failed == 0 then
                    if #paths == 1 then
                        vim.notify("File reverted: " .. relative_path(paths[1]), vim.log.levels.INFO, { title = "Neo-tree 󰹩" })
                    else
                        vim.notify("Reverted " .. tostring(#paths) .. " selected file(s)", vim.log.levels.INFO, { title = "Neo-tree 󰹩" })
                    end
                    clear_multiselect(state)
                else
                    vim.notify("Git restore failed: " .. relative_path(failed[1].path), vim.log.levels.ERROR, { title = "Neo-tree 󰹩" })
                end

                refresh_source(state, "git_status")
            end)
        end

        local layout = require("utils.layout")

        local multiselect_by_source = {}

        local function patch_neotree_name_component()
            local ok_components, components = pcall(require, "neo-tree.sources.common.components")
            if not ok_components or type(components.name) ~= "function" then
                return
            end
            if components._multiselect_name_patched then
                return
            end

            local original_name = components.name
            components.name = function(config, node, state)
                local result = original_name(config, node, state)
                local selected = multiselect_by_source[(state and state.name) or "filesystem"]

                if node and node.type ~= "directory" and selected and selected.lookup[node:get_id()] then
                    if type(result) == "table" and result.text then
                        result.highlight = "NeoTreeMultiSelectName"
                    end
                end

                return result
            end

            components._multiselect_name_patched = true
        end

        get_multiselect_state = function(state)
            local source = (state and state.name) or "filesystem"
            if not multiselect_by_source[source] then
                multiselect_by_source[source] = { order = {}, lookup = {} }
            end
            return multiselect_by_source[source], source
        end

        clear_multiselect = function(state)
            local selected, source = get_multiselect_state(state)
            selected.order = {}
            selected.lookup = {}
            local ok, manager = pcall(require, "neo-tree.sources.manager")
            if ok then
                manager.refresh(source)
            end
        end

        local function toggle_multiselect(state, move_direction)
            local node = state.tree:get_node()
            if not node then return end
            if node.type == "directory" then return end

            local selected, source = get_multiselect_state(state)
            local id = node:get_id()
            if selected.lookup[id] then
                selected.lookup[id] = nil
                for idx, entry in ipairs(selected.order) do
                    if entry.id == id then
                        table.remove(selected.order, idx)
                        break
                    end
                end
            else
                selected.lookup[id] = true
                table.insert(selected.order, {
                    id = id,
                    path = node.path,
                })
            end

            local ok, manager = pcall(require, "neo-tree.sources.manager")
            if ok then
                manager.refresh(source)
            end

            if move_direction == "next" then
                vim.cmd("normal! j")
            elseif move_direction == "prev" then
                vim.cmd("normal! k")
            end
        end

        local function open_multiselect_or_current(state)
            local targets = get_selected_paths_or_current(state, {
                allow = function(path)
                    return type(path) == "string" and vim.fn.filereadable(path) == 1
                end,
            })

            if #targets == 0 then
                local ok_cmd, source_commands = pcall(require, "neo-tree.sources." .. state.name .. ".commands")
                if ok_cmd and type(source_commands.open) == "function" then
                    source_commands.open(state)
                end
                return
            end

            if vim.bo.filetype == "neo-tree" then
                vim.cmd("wincmd p")
            end

            for _, path in ipairs(targets) do
                vim.cmd("edit " .. vim.fn.fnameescape(path))
            end

            clear_multiselect(state)
        end

        patch_neotree_name_component()

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
                    provider = function(icon, node, state)
                        if node.type == "file" or node.type == "terminal" then
                            local success, web_devicons = pcall(require, "nvim-web-devicons")
                            local name = node.type == "terminal" and "terminal" or node.name
                            if success then
                                local devicon, hl = web_devicons.get_icon(name)
                                icon.text = devicon or icon.text
                                icon.highlight = hl or icon.highlight
                            end
                        end

                        local selected = multiselect_by_source[(state and state.name) or "filesystem"]
                        if node.type ~= "directory" and selected and selected.lookup[node:get_id()] then
                            icon.text = "✚ " .. icon.text
                            icon.highlight = "NeoTreeMultiSelectName"
                        end

                        return icon
                    end,
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
            close_if_last_window = false,
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
                    ["<cr>"] = open_multiselect_or_current,
                    ["<Tab>"] = function(state)
                        toggle_multiselect(state, "next")
                    end,
                    ["<S-Tab>"] = function(state)
                        toggle_multiselect(state, "prev")
                    end,
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
                        ["d"] = delete_selected_buffers_or_current,
                    },
                },
            },

            enable_git_status = true,
            git_status = {
                window = {
                    position = "float",
                    mappings = {
                        ["a"] = git_add_selected_or_current,
                        ["u"] = git_unstage_selected_or_current,
                        ["r"] = git_revert_selected_or_current,
                        ["c"] = "git_commit",
                        ["p"] = "git_push",
                        ["g"] = "git_commit_and_push",

                        ["A"] = "git_add_all",
                        ["U"] = function(state)
                            local ok, out = git_exec(state, { "git", "reset" })
                            if not ok then
                                vim.notify("Git reset failed: " .. out, vim.log.levels.ERROR, {title = "Neo-tree 󰹩"})
                            end
                            require("neo-tree.sources.git_status").refresh(state)
                        end,
                        ["R"] = function(state)
                            git_confirm("Revert ALL files?", function()
                                local ok, out = git_exec(state, { "git", "restore", "--", ":/" })
                                if ok then
                                    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                                        local name = vim.api.nvim_buf_get_name(bufnr)
                                        if vim.api.nvim_buf_is_loaded(bufnr) and vim.fn.filereadable(name) == 1 then
                                            pcall(vim.cmd, "silent checktime " .. bufnr)
                                        end
                                    end
                                    vim.notify("All files reverted and buffers reloaded.", vim.log.levels.INFO, {title = "Neo-tree 󰹩"})
                                else
                                    vim.notify("Git restore failed: " .. out, vim.log.levels.ERROR, {title = "Neo-tree 󰹩"})
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
                        -- lock Neo-tree’s width so horizontal splits don’t span it
                        local winid = vim.api.nvim_get_current_win()
                        pcall(vim.api.nvim_set_option_value, "winfixwidth", true, { win = winid })

                        layout.defer_reflow(60)

                        if type(args) == "table" and args.source and args.position ~= "float" then
                            last_neotree_source = args.source
                        end

                        local buf = vim.api.nvim_win_get_buf(winid)
                        local function clear_columns()
                            if not vim.api.nvim_win_is_valid(winid) then return end
                            pcall(vim.api.nvim_set_option_value, "statuscolumn", "", { win = winid })
                            pcall(vim.api.nvim_set_option_value, "foldcolumn", "0", { win = winid })
                            pcall(vim.api.nvim_set_option_value, "signcolumn", "no", { win = winid })

                            local ok, gs = pcall(require, "gitsigns")
                            if ok then pcall(gs.detach, buf) end
                        end

                        vim.defer_fn(clear_columns, 50)
                    end,
                },
                {
                    event = "file_added",
                    handler = function(filepath)
                        vim.notify("File added: " .. relative_path(filepath), vim.log.levels.INFO, {title = "Neo-tree 󰹩"})
                    end,
                },
                {
                    event = "file_deleted",
                    handler = function(filepath)
                        vim.notify("File deleted: " .. relative_path(filepath), vim.log.levels.WARN, {title = "Neo-tree 󰹩"})
                    end,
                },
                {
                    event = "file_moved",
                    handler = function(info)
                        vim.notify("File moved: " .. relative_path(info.source) .. " → " .. relative_path(info.destination), vim.log.levels.INFO, {title = "Neo-tree 󰹩"})
                    end,
                },
                {
                    event = "file_renamed",
                    handler = function(info)
                        vim.notify("File renamed: " .. relative_path(info.source) .. " → " .. relative_path(info.destination), vim.log.levels.INFO, {title = "Neo-tree 󰹩"})
                    end,
                },
            }
        })

        vim.api.nvim_create_autocmd("BufWinLeave", {
            group = vim.api.nvim_create_augroup("neotree_reflow_on_close", { clear = true }),
            callback = function(ev)
                if vim.api.nvim_buf_is_valid(ev.buf) and vim.bo[ev.buf].filetype == "neo-tree" then
                    layout.defer_reflow(50)
                end
            end,
        })

        vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "TermClose" }, {
            group = vim.api.nvim_create_augroup("neotree_track_buffers", { clear = true }),
            callback = function()
                layout.refresh_neotree_buffers()
            end,
        })

        vim.api.nvim_create_autocmd("QuitPre", {
            group = vim.api.nvim_create_augroup("neotree_close_if_last", { clear = true }),
            callback = function()
                local cur = vim.api.nvim_get_current_win()
                if layout.is_panel(vim.api.nvim_win_get_buf(cur), cur) then
                    return
                end

                local panel_wins, editor_wins = {}, 0
                for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                    local ok, cfg = pcall(vim.api.nvim_win_get_config, win)
                    if ok and cfg and (not cfg.relative or cfg.relative == "") then
                        if layout.is_panel(vim.api.nvim_win_get_buf(win), win) then
                            table.insert(panel_wins, win)
                        else
                            editor_wins = editor_wins + 1
                        end
                    end
                end

                if #panel_wins > 0 and editor_wins == 1 then
                    for _, win in ipairs(panel_wins) do
                        pcall(vim.api.nvim_win_close, win, true)
                    end
                end
            end,
        })

        apply_neotree_orange_highlights()
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("neotree_highlights", { clear = true }),
            callback = function()
                apply_neotree_orange_highlights()
            end,
        })

        vim.keymap.set('n', '<leader>n', toggle_last_neotree, { noremap = true, silent = true, desc = "Neotree: Toggle" })
    end
}
