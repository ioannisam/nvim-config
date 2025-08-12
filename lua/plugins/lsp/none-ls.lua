return {
    {
        "jay-babu/mason-null-ls.nvim",
        dependencies = { "williamboman/mason.nvim", "nvimtools/none-ls.nvim" },
        config = function()
            require("mason-null-ls").setup({
                ensure_installed = {
                    -- Lua
                    "stylua",
                    "selene",

                    -- Shell
                    -- "shellharden",
                    "shfmt",

                    -- C / C++
                    "clang-format",
                    "cpplint",

                    -- Python
                    "black",
                    "flake8",
                    "mypy",

                    -- LaTeX

                    -- Markdown / Writing
                    "textlint",
                    "markdownlint",
                    "proselint",
                    "write-good",
                    "codespell",

                    -- Git
                    "commitlint",
                    "gitlint",

                    -- Docker
                    "hadolint",
                },
                automatic_installation = false,
            })
        end,
    },
    {
        "nvimtools/none-ls.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvimtools/none-ls-extras.nvim",
        },
        config = function()
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {

                    -- Lua
                    null_ls.builtins.formatting.stylua,
                    -- null_ls.builtins.diagnostics.selene,

                    -- Shell
                    -- null_ls.builtins.formatting.shellharden,
                    null_ls.builtins.formatting.shfmt,

                    -- C / C++
                    null_ls.builtins.diagnostics.cppcheck,
                    null_ls.builtins.formatting.clang_format,
                    require("none-ls.diagnostics.cpplint"),

                    -- Python
                    null_ls.builtins.formatting.black,
                    require("none-ls.diagnostics.flake8"),
                    null_ls.builtins.diagnostics.mypy,

                    -- LaTeX
                    null_ls.builtins.diagnostics.textidote,

                    -- Markdown
                    null_ls.builtins.formatting.textlint,
                    null_ls.builtins.diagnostics.markdownlint,
                    null_ls.builtins.code_actions.proselint,
                    null_ls.builtins.diagnostics.write_good,
                    null_ls.builtins.diagnostics.codespell,
                    null_ls.builtins.completion.spell,
                    null_ls.builtins.hover.dictionary,
                    null_ls.builtins.hover.printenv,

                    -- Git
                    null_ls.builtins.code_actions.gitsigns,
                    null_ls.builtins.diagnostics.commitlint,
                    null_ls.builtins.diagnostics.gitlint,

                    -- Docker
                    null_ls.builtins.diagnostics.hadolint,
                },
            })
        end,
    },
}
