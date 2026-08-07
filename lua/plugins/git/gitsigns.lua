return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local gs = require("gitsigns")

        local diff_ui = false
        local function apply_signcolumn(win)
            if not vim.api.nvim_win_is_valid(win) then
                return
            end
            if vim.bo[vim.api.nvim_win_get_buf(win)].buftype ~= "" then
                return
            end
            vim.api.nvim_set_option_value("signcolumn", diff_ui and "no" or "yes", { win = win })
        end

        vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
            group = vim.api.nvim_create_augroup("gitsigns_diff_ui_signcolumn", { clear = true }),
            callback = function()
                apply_signcolumn(vim.api.nvim_get_current_win())
            end,
        })

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

                local map = function(lhs, rhs, desc)
                    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, noremap = true, silent = true, desc = desc })
                end

                map("<leader>gt", function()
                    diff_ui = gs.toggle_word_diff()
                    gs.toggle_numhl(diff_ui)
                    gs.toggle_linehl(diff_ui)

                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        apply_signcolumn(win)
                    end

                    vim.notify(
                        diff_ui and "Diff UI ON" or "Diff UI OFF",
                        vim.log.levels.INFO,
                        {title = "Gitsigns "}
                    )
                end, "Git: Toggle diff UI")

                map("<leader>gn", function() gs.nav_hunk("next") end, "Git: Next hunk")
                map("<leader>gp", function() gs.nav_hunk("prev") end, "Git: Previous hunk")
                map("<leader>gd", gs.preview_hunk_inline, "Git: Preview hunk inline")

                map("<leader>gD", function()
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
                end, "Git: Preview hunk window")
                map("<leader>gb", gs.blame_line, "Git: Blame line")
                map("<leader>gr", gs.reset_hunk, "Git: Reset hunk")
            end,
        })
    end,
}
