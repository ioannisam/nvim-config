return {
    {
        "jay-babu/mason-null-ls.nvim",
        dependencies = { "williamboman/mason.nvim", "nvimtools/none-ls.nvim" },
        config = function()
            require("mason-null-ls").setup({
                ensure_installed = {
                    "stylua",
                    "clang-format",
                    "cpplint",
                    "shellcheck",
                    "shfmt",
                    "latexindent",
                    "markdownlint",
                    "prettier",
                    "black",
                    "flake8",
                    "mypy",
                },
                automatic_installation = true,
            })
        end,
    },
    {
        "nvimtools/none-ls.nvim",
        config = function()
            local null_ls = require("null-ls")

            local formatting = null_ls.builtins.formatting
            local diagnostics = null_ls.builtins.diagnostics

            local on_attach = function(client, bufnr)
                local bufmap = function(mode, lhs, rhs)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
                end

                bufmap("n", "gd", vim.lsp.buf.definition)
                bufmap("n", "H", vim.lsp.buf.hover) -- find new keymap for H
                bufmap("n", "<leader>rn", vim.lsp.buf.rename)
                bufmap("n", "<leader>ca", vim.lsp.buf.code_action)
                bufmap("n", "gr", vim.lsp.buf.references)

                bufmap("n", "<leader>lf", function()
                    vim.lsp.buf.format({
                        async = true,
                        bufnr = bufnr,
                    })
                end)

                vim.diagnostic.config({
                    update_in_insert = false,
                })
            end

            null_ls.setup({
                sources = {
                    -- Lua
                    formatting.stylua,

                    -- Bash
                    diagnostics.shellcheck,
                    formatting.shfmt,

                    -- C/C++
                    formatting.clang_format,
                    diagnostics.cpplint,

                    -- Python
                    formatting.black,
                    diagnostics.flake8,
                    diagnostics.mypy,

                    -- LaTeX
                    formatting.latexindent,

                    -- Markdown
                    diagnostics.markdownlint,
                    formatting.prettier.with({
                        filetypes = { "markdown", "json", "yaml" },
                    }),
                },
                on_attach = on_attach,
            })
        end,
    },
}
