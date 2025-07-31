return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
        signs = true,
        sign_priority = 8,
        keywords = {
            FIX = {
                icon = " ",
                color = "error",
                alt = { "BUG", "ISSUE" },
            },
            TODO = {
                icon = " ",
                color = "work",
            },
            WARN = {
                icon = " ",
                color = "warning",
                alt = { "WARNING", "XXX" },
            },
            INFO = {
                icon = " ",
                color = "hint",
                alt = { "NOTE" },
            },
            TEST = {
                icon = "󰂓 ",
                color = "experiment",
                alt = { "TESTING", "PASSED", "FAILED" },
            },
            LIMIT = {
                icon = "󰟾 ",
                color = "cap",
                alt = { "LIMITATION" },
            },
        },
        gui_style = {
            fg = "NONE",
            bg = "BOLD",
        },
        merge_keywords = true,
        highlight = {
            multiline = true,
            multiline_pattern = "^.",
            multiline_context = 10,
            before = "",
            keyword = "wide",
            after = "fg",
            pattern = [[.*<(KEYWORDS)\s*:]],
            comments_only = true,
            max_line_len = 400,
            exclude = {},
        },
        colors = {

            error = { "DiagnosticError", "ErrorMsg", "#F38BA8" },
            warning = "#F9E2AF",
            hint    = "#89B4FA",
            work    = "#A6E3A1",
            experiment   = "#CBA6F7",
            cap   = "#FAB387",
        },
        search = {
            command = "rg",
            args = {
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
            },
            pattern = [[\b(KEYWORDS):]],
        },
    },
    config = function(_, opts)
        require("todo-comments").setup(opts)
        vim.keymap.set("n", "<leader>cq", "<cmd>TodoQuickFix<CR>", { desc = "Todo: Quickfix List" })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "qf",
            callback = function(args)
                vim.keymap.set("n", "<Esc>", "<cmd>cclose | lclose<CR>", {
                    buffer = args.buf,
                    silent = true,
                    desc = "Close loclist/quickfix on Esc",
                })
            end,
        })
    end,

}
