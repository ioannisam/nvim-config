-- TODO: 
--     Hover 'x' functionality
--     Middle mouse

return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "famiu/bufdelete.nvim",
    },
    config = function()

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
                left_mouse_command = "buffer %d",
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

        local function is_excluded(bufnr)
            if not (vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr)) then
                return true, "invalid"
            end

            local buftype = vim.bo[bufnr].buftype
            local filetype = vim.bo[bufnr].filetype
            local name = vim.api.nvim_buf_get_name(bufnr)
            local wtype = vim.fn.win_gettype()

            local excluded_filetypes = {
                "neo-tree", "NvimTree",
                "undotree",
                "spectre", "spectre_panel", "TelescopePrompt", "TelescopeResults",
                "dap-repl",
                "qf", "Trouble", "neotest-summary", "Outline",
                "help", "man", "lspinfo",
                "gitcommit", "alpha", "noice", "copilot",
                "lazy", "mason",
                "fugitive",
                "notify",
            }

            if buftype ~= "" then
                if buftype == "terminal" and vim.b[bufnr].native_term then
                    -- allowed: native terminal
                else
                    return true, "special buftype"
                end
            end
            if filetype and vim.tbl_contains(excluded_filetypes, filetype) then
                return true, "excluded filetype: " .. filetype
            end
            if wtype ~= "" and wtype ~= "normal" then
                return true, "special window type"
            end
            if vim.b[bufnr].bufferline_exclude then
                return true, "explicitly excluded"
            end

            return false
        end

        local function buffer_is_pinned(bufnr)
            local ok, groups = pcall(require, "bufferline.groups")
            if ok and type(groups._is_pinned) == "function" then
                return groups._is_pinned({ id = bufnr })
            end
            return false
        end

        local function goto_buffer(i)
            pcall(vim.cmd, ("BufferLineGoToBuffer %d"):format(i))
        end

        for i = 1, 9 do
            local idx = i
            vim.keymap.set("n", tostring(idx), function()
                local cur = vim.api.nvim_get_current_buf()
                local excluded, _ = is_excluded(cur)
                if excluded then
                    -- jump to first normal window with a non-excluded buffer
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local b = vim.api.nvim_win_get_buf(win)
                        local exc = is_excluded(b)
                        if not exc then
                            vim.api.nvim_set_current_win(win)
                            break
                        end
                    end
                end
                goto_buffer(idx)
            end, { noremap = true, silent = true, nowait = true, desc = "Go to buffer " .. idx })
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
            end
        end, { desc = "New buffer on double-click bufferline (centered input)" })
    end,
}
