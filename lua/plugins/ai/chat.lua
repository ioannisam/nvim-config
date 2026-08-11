return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            { "zbirenbaum/copilot.lua" },
            { "nvim-lua/plenary.nvim", branch = "master" },
        },
        build = "make tiktoken",
        opts = {
            debug = false,
            window = {
                layout = "vertical",
                width = 0.3,
                height = 0.5,
            },
            mappings = {
                complete = {
                    insert = '<Tab>',
                },
                close = {
                    normal = 'q',
                    insert = '<C-c>',
                },
                reset = {
                    normal = '<C-l>',
                    insert = '<C-l>',
                },
                submit_prompt = {
                    normal = '<CR>',
                    insert = '<C-s>',
                },
                toggle_sticky = {
                    normal = 'grr',
                },
                clear_stickies = {
                    normal = 'grx',
                },
                accept_diff = {
                    normal = '<C-y>',
                    insert = '<C-y>',
                },
                jump_to_diff = {
                    normal = 'gj',
                },
                quickfix_answers = {
                    normal = 'gqa',
                },
                quickfix_diffs = {
                    normal = 'gqd',
                },
                yank_diff = {
                    normal = 'gy',
                    register = '"',
                },
                show_diff = {
                    normal = 'gd',
                    full_diff = false,
                },
                show_info = {
                    normal = 'gi',
                },
                show_context = {
                    normal = 'gc',
                },
                show_help = {
                    normal = 'gh',
                },
            },
        },
        config = function(_, opts)
            require("CopilotChat").setup(opts)

            vim.api.nvim_create_autocmd({ "BufWinEnter", "WinNew" }, {
                group = vim.api.nvim_create_augroup("copilotchat_fix_width", { clear = true }),
                callback = function()
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "copilot-chat" then
                            pcall(vim.api.nvim_set_option_value, "winfixwidth", true, { win = win })
                        end
                    end
                end,
            })
        end,
        keys = {
            {
                "<leader>cc",
                function()
                    require("utils.special_windows").open("copilotchat", function()
                        vim.schedule(function()
                            require("CopilotChat").toggle()
                        end)
                    end)
                end,
                desc = "Toggle Copilot Chat",
            },
        },
    }
}
