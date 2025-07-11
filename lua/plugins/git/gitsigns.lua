return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local gs = require("gitsigns")

        gs.setup({
            sign_priority = 6,
            update_debounce = 200,

            signs = {
                add          = { text = '┃' },
                change       = { text = '┃' },
                delete       = { text = '_' },
                topdelete    = { text = '‾' },
                changedelete = { text = '~' },
                untracked    = { text = '' },
            },

            signcolumn = true,
            numhl      = false,
            linehl     = false,
            word_diff  = false,

            current_line_blame = false,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol",
                delay = 2000,
                ignore_whitespace = false,
            },

            preview_config = {
                border = "rounded",
                style = "minimal",
                relative = "cursor",
                focusable = true,
                row = 0,
                col = 1,
            },
            attach_to_untracked = false,
            on_attach = function(bufnr)

                local opts = { buffer = bufnr, noremap = true, silent = true }
                vim.keymap.set("n", "<leader>gt", function()
                    gs.toggle_word_diff()
                    gs.toggle_numhl()
                    gs.toggle_linehl()

                    local current = vim.wo.signcolumn
                    if current == "yes" then
                        vim.wo.signcolumn = "no"
                        vim.notify("Gitsigns: Diff UI OFF", vim.log.levels.INFO)
                    else
                        vim.wo.signcolumn = "yes"
                        vim.notify("Gitsigns: Diff UI ON", vim.log.levels.INFO)
                    end
                end, opts)

                vim.keymap.set("n", "<leader>gn", gs.next_hunk, opts)
                vim.keymap.set("n", "<leader>gp", gs.prev_hunk, opts)
                vim.keymap.set("n", "<leader>gd", gs.preview_hunk_inline, opts)

                vim.keymap.set("n", "<leader>gD", function()
                    gs.preview_hunk()

                    vim.defer_fn(function()
                        for _, win in ipairs(vim.api.nvim_list_wins()) do
                            local config = vim.api.nvim_win_get_config(win)
                            if config.relative ~= "" then
                                vim.api.nvim_set_current_win(win)
                                vim.keymap.set("n", "<Esc>", function()
                                    vim.api.nvim_win_close(win, true)
                                end, { buffer = vim.api.nvim_win_get_buf(win), nowait = true })
                                break
                            end
                        end
                    end, 20)
                end, opts)
                vim.keymap.set("n", "<leader>gb", gs.blame_line, opts)
                vim.keymap.set("n", "<leader>gr", gs.reset_hunk, opts)
            end,
        })
    end,
}
