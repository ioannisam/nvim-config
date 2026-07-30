return {
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim", branch = "master" },
            "nvim-treesitter/nvim-treesitter",
        },
        cmd = {
            "CodeCompanion",
            "CodeCompanionChat",
            "CodeCompanionActions",
            "CodeCompanionCmd",
            "CodeCompanionCodeReview",
        },
        opts = {
            adapters = {
                http = {
                    extend = {
                        anthropic = {
                            schema = {
                                model = {
                                    -- Swap for "claude-sonnet-5" for a cheaper/faster default.
                                    default = "claude-opus-5",
                                },
                            },
                        },
                    },
                },
            },
            interactions = {
                chat = { adapter = "anthropic" },
                inline = { adapter = "anthropic" },
                cmd = { adapter = "anthropic" },
            },
            display = {
                chat = {
                    window = {
                        layout = "vertical",
                        position = "right",
                        full_height = true,
                        width = 0.3,
                        border = "single",
                    },
                    show_settings = false,
                    show_token_count = true,
                },
                action_palette = {
                    provider = "telescope",
                },
                diff = {
                    enabled = true,
                },
            },
            opts = {
                log_level = "ERROR",
            },
        },
        config = function(_, opts)
            require("codecompanion").setup(opts)

            if vim.env.ANTHROPIC_API_KEY == nil or vim.env.ANTHROPIC_API_KEY == "" then
                vim.notify(
                    "ANTHROPIC_API_KEY is not set; the Anthropic adapter will fail to authenticate.",
                    vim.log.levels.WARN,
                    { title = "CodeCompanion 󰚩" }
                )
            end
        end,
        keys = {
            {
                "<leader>ca",
                "<cmd>CodeCompanionChat Toggle<cr>",
                desc = "Toggle CodeCompanion Chat",
            },
            {
                "<leader>cA",
                "<cmd>CodeCompanionChat Add<cr>",
                mode = "x",
                desc = "Add selection to CodeCompanion Chat",
            },
            {
                "<leader>ci",
                ":CodeCompanion ",
                mode = { "n", "x" },
                desc = "CodeCompanion inline assistant",
            },
            {
                "<leader>cp",
                "<cmd>CodeCompanionActions<cr>",
                mode = { "n", "x" },
                desc = "CodeCompanion action palette",
            },
        },
    },
}
