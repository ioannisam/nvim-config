-- TODO: 
--     Pinned buffer deletion
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
                                fg = "#fab387",
                                -- fg = "#cba6f7",
                                bold = true,
                                underline = true,
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
            }

            if buftype ~= "" or not vim.bo[bufnr].buflisted then
                return true, "special buftype"
            end
            if filetype and vim.tbl_contains(excluded_filetypes, filetype) then
                return true, "excluded filetype: " .. filetype
            end
            if wtype ~= "" and wtype ~= "normal" then
                return true, "special window type"
            end
            if name == "" and (not filetype or filetype == "") then
                return true, "unnamed"
            end
            if vim.b[bufnr].bufferline_exclude then
                return true, "explicitly excluded"
            end

            return false
        end

        vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "BufWinEnter" }, {
            callback = function()
                for i = 1, 9 do
                    vim.keymap.set("n", tostring(i), function()
                        local bufnr = vim.api.nvim_get_current_buf()
                        local excluded, _ = is_excluded(bufnr)
                        if excluded then
                            -- jump to first "normal" window with a non-excluded buffer
                            for _, win in ipairs(vim.api.nvim_list_wins()) do
                                local b = vim.api.nvim_win_get_buf(win)
                                local exc, _ = is_excluded(b)
                                if not exc then
                                    vim.api.nvim_set_current_win(win)
                                    break
                                end
                            end
                        end

                        pcall(require("bufferline").go_to_buffer, i, true)
                    end, { buffer = bufnr, noremap = true, silent = true })
                end
            end,
        })

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

        vim.keymap.set("n", "<leader>bd", function()
            local bufnum = vim.api.nvim_get_current_buf()
            local excluded, reason = is_excluded(bufnum)
            if excluded then
                vim.notify("Cannot delete this buffer (" .. reason .. ")", vim.log.levels.WARN)
                return
            end

            require("bufdelete").bufdelete(bufnum, true)
        end, { noremap = true, silent = true, desc = "Delete current buffer (if not pinned/excluded)" })
    end,
}
