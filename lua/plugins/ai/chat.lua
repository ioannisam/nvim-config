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
        keys = {
            {
                "<leader>cc",
                function()
                    local special_windows = require("utils.special_windows")
                    if special_windows.is_open("copilotchat") then
                        require("CopilotChat").toggle()
                        return
                    end

                    local had_neotree = special_windows.is_open("neotree")
                    special_windows.prepare_for_open("copilotchat")

                    if had_neotree then
                        vim.cmd("wincmd =")
                    end

                    vim.schedule(function()
                        require("CopilotChat").toggle()
                    end)
                end,
                desc = "Toggle Copilot Chat",
            },
        },
    }
}
