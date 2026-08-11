return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "famiu/bufdelete.nvim",
    },
    config = function()
        local focus_main_window

        require("bufferline").setup({
            options = {
                mode = "buffers",
                numbers = "ordinal",

                close_command = function(bufnr)
                    if vim.api.nvim_buf_is_valid(bufnr) then
                        require("bufdelete").bufdelete(bufnr, true)
                    end
                end,

                right_mouse_command = function(bufnr)
                    if vim.api.nvim_buf_is_valid(bufnr) then
                        require("bufdelete").bufdelete(bufnr, true)
                    end
                end,
                left_mouse_command = function(bufnr)
                    if not vim.api.nvim_buf_is_valid(bufnr) then
                        return
                    end

                    if focus_main_window and not focus_main_window(true) then
                        vim.notify("No main buffer window available", vim.log.levels.WARN, { title = "Bufferline " })
                        return
                    end

                    vim.api.nvim_set_current_buf(bufnr)
                end,
                middle_mouse_command = nil,

                indicator = {
                    icon = "▎",
                    style = "icon",
                },
                buffer_close_icon = " ",
                close_icon = "",
                modified_icon = " ●",
                left_trunc_marker = "",
                right_trunc_marker = "",

                diagnostics = "nvim_lsp",
                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "File Explorer",
                        text_align = "center",
                        separator = true,
                    },
                    {
                        filetype = "undotree",
                        text = "Undo Tree",
                        text_align = "center",
                        separator = true,
                    },
                },

                show_buffer_icons = true,
                show_buffer_close_icons = true,
                show_close_icon = true,
                show_tab_indicators = true,
                persist_buffer_sort = true,
                separator_style = "slant",
                enforce_regular_tabs = false,
                always_show_bufferline = true,
                show_bufferline_in_all_windows = false,
                hover = {
                    enabled = false,
                    delay = 200,
                    reveal = { "close" },
                },

                groups = {
                    options = {
                        toggle_hidden_on_enter = true,
                        separator = false,
                    },
                    items = {
                        require("bufferline.groups").builtin.pinned:with({
                            icon = "󰐃",
                            highlight = {
                                fg = "#8aadf4",
                                -- fg = "#fab387",
                                -- fg = "#cba6f7",
                                bold = true,
                                underline = false,
                            },
                            priority = 1,
                        }),
                    },
                },

                custom_areas = {
                    right = function()
                        local result = {}
                        local seve = vim.diagnostic.severity

                        local error = #vim.diagnostic.get(0, { severity = seve.ERROR })
                        if error ~= 0 then
                            table.insert(result, { text = "  " .. error, link = "DiagnosticError" })
                        end

                        local warning = #vim.diagnostic.get(0, { severity = seve.WARN })
                        if warning ~= 0 then
                            table.insert(result, { text = "  " .. warning, link = "DiagnosticWarn" })
                        end

                        local hint = #vim.diagnostic.get(0, { severity = seve.HINT })
                        if hint ~= 0 then
                            table.insert(result, { text = "  " .. hint, link = "DiagnosticHint" })
                        end

                        local info = #vim.diagnostic.get(0, { severity = seve.INFO })
                        if info ~= 0 then
                            table.insert(result, { text = "  " .. info, link = "DiagnosticInfo" })
                        end
                        return result
                    end,
                },
            },
        })

        local layout = require("utils.layout")

        local is_excluded = layout.is_panel

        focus_main_window = function(silent)
            return layout.focus_main_win({ silent = silent, title = "Bufferline " })
        end

        local function buffer_is_pinned(bufnr)
            local name = vim.api.nvim_buf_get_name(bufnr)
            if name == "" then
                return false
            end

            local raw = vim.g.BufferlinePinnedBuffers
            if type(raw) ~= "string" or raw == "" then
                return false
            end

            for _, pinned in ipairs(vim.split(raw, ",", { trimempty = true })) do
                if pinned == name then
                    return true
                end
            end
            return false
        end

        local function goto_buffer(i)
            pcall(vim.cmd, ("BufferLineGoToBuffer %d"):format(i))
        end

        for i = 1, 9 do
            local idx = i
            local function jump()
                if not focus_main_window(false) then
                    return
                end
                goto_buffer(idx)
            end
            for _, lhs in ipairs({ "<A-" .. idx .. ">", "<leader>" .. idx }) do
                vim.keymap.set("n", lhs, jump, {
                    noremap = true,
                    silent = true,
                    desc = "Go to buffer " .. idx,
                })
            end
        end

        vim.keymap.set("n", "<leader>bd", function()
            local bufnum = vim.api.nvim_get_current_buf()
            local buftype = vim.bo[bufnum].buftype

            if buftype == "terminal" then
                if not vim.b[bufnum].native_term then
                    vim.notify("This is a toggleterm terminal — delete with <leader>td", vim.log.levels.WARN, {title = "Bufferline "})
                    return
                end
            end

            if buffer_is_pinned(bufnum) then
                vim.notify("Pinned buffers cannot be deleted", vim.log.levels.WARN, {title = "Bufferline "})
                return
            end

            local excluded, reason = is_excluded(bufnum)
            if excluded then
                vim.notify("Cannot delete this buffer (" .. reason .. ")", vim.log.levels.WARN, {title = "Bufferline "})
                return
            end

            if vim.bo[bufnum].modified then
                local choice = vim.fn.confirm(
                    "Buffer has unsaved changes. Delete anyway?",
                    "&Yes\n&No",
                    2
                )
                if choice ~= 1 then
                    vim.notify("Buffer deletion cancelled", vim.log.levels.INFO, {title = "Bufferline "})
                    return
                end
            end
            require("bufdelete").bufdelete(bufnum, true)
            vim.notify("Buffer deleted", vim.log.levels.INFO, {title = "Bufferline "})
        end, { noremap = true, silent = true, desc = "Delete current buffer (native terminal allowed)" })

        vim.keymap.set("n", "<leader>bD", function()
            local picker = require("utils.picker")

            local ordered = {}
            local ok_elements, elements = pcall(function()
                vim.cmd("redrawtabline")
                return require("bufferline").get_elements().elements
            end)
            if ok_elements then
                for _, element in ipairs(elements) do
                    table.insert(ordered, element.id)
                end
            end

            local entries = {}
            for idx, bufnr in ipairs(ordered) do
                if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
                    -- reuse your existing helpers (is_excluded, buffer_is_pinned)
                    local excluded, _ = is_excluded(bufnr)
                    if not excluded and not buffer_is_pinned(bufnr) then
                        table.insert(entries, {
                            bufnr = bufnr,
                            ordinal = idx,
                            name = vim.api.nvim_buf_get_name(bufnr),
                        })
                    end
                end
            end

            if #entries == 0 then
                vim.notify("No buffers available to delete", vim.log.levels.INFO, { title = "Buffer Deleter" })
                return
            end

            picker.multiselect(entries, {
                prompt = "Select buffers to delete:",
                format_item = function(b)
                    local name = (b.name ~= "" and vim.fn.fnamemodify(b.name, ":t")) or "[No Name]"
                    return string.format("[%d] %s", b.ordinal, name)
                end,
            }, function(selected)
                    for _, e in ipairs(selected) do
                        if vim.api.nvim_buf_is_valid(e.bufnr) then
                            require("bufdelete").bufdelete(e.bufnr, true)
                        end
                    end
                end)
        end, { noremap = true, silent = true, desc = "Delete buffers via Telescope (bufferline ordinals)" })

        vim.keymap.set("n", "<leader>bn", "<Cmd>BufferLineCycleNext<CR>", {
            noremap = true,
            silent = true,
            desc = "Next buffer in bufferline order",
        })
        vim.keymap.set("n", "<leader>bp", "<Cmd>BufferLineCyclePrev<CR>", {
            noremap = true,
            silent = true,
            desc = "Previous buffer in bufferline order",
        })

        vim.keymap.set("n", "<leader>bl", "<Cmd>BufferLineMoveNext<CR>", {
            noremap = true,
            silent = true,
            desc = "Move buffer right",
        })
        vim.keymap.set("n", "<leader>bh", "<Cmd>BufferLineMovePrev<CR>", {
            noremap = true,
            silent = true,
            desc = "Move buffer left",
        })

        vim.keymap.set(
            "n",
            "<leader>bb",
            "<Cmd>BufferLineTogglePin<CR>",
            { noremap = true, silent = true, desc = "Toggle pin buffer" }
        )

        local function new_file_dialog()
            vim.ui.input({ prompt = "New file name: ", default = "untitled" }, function(input)
                if input and input ~= "" then
                    vim.cmd("e " .. vim.fn.fnameescape(input))
                    vim.cmd("startinsert")
                end
            end)
        end

        vim.keymap.set("n", "<leader>bf", new_file_dialog, { noremap = true, silent = true, desc = "Create new file (floating)" })
        vim.keymap.set("n", "<2-LeftMouse>", function()
            local mp = vim.fn.getmousepos()
            if mp.screenrow == 1 then
                new_file_dialog()
                return
            end
            
            vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes("<2-LeftMouse>", true, false, true),
                "n",
                false
            )
        end, { desc = "New buffer on double-click bufferline (centered input)" })
    end,
}
