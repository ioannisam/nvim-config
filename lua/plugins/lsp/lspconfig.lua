return {
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
        opts = {
            ensure_installed = {
                "vimls",
                "lua_ls",
                "bashls",
                -- "rust_analyzer",
                "clangd",
                "pyright",
                "texlab",
                "ltex",
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            if cmp_ok then
                capabilities = cmp_nvim_lsp.default_capabilities()
            end

            local on_attach = function(client, bufnr)
                local navic_ok, navic = pcall(require, "nvim-navic")
                if navic_ok and client.server_capabilities.documentSymbolProvider then
                    navic.attach(client, bufnr)
                end

                local bufmap = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
                end

                bufmap("n", "gd", vim.lsp.buf.definition, "LSP: Go to definition")
                bufmap("n", "qi", vim.lsp.buf.hover, "LSP: Hover documentation")
                bufmap("n", "<leader>lr", vim.lsp.buf.rename, "LSP: Rename symbol")
                bufmap("n", "<leader>la", vim.lsp.buf.code_action, "LSP: Code actions")
                bufmap("n", "gr", vim.lsp.buf.references, "LSP: List references")

                bufmap("n", "<leader>lf", function()
                    vim.lsp.buf.format({
                        async = true,
                        bufnr = bufnr,
                    })
                end, "LSP: Format buffer")
            end

            local ltex_settings = {
                language = "en",
                dictionary = {
                    ["en"] = {},
                    ["el"] = {},
                },
                enabled = { "latex", "markdown", "text" },
                languages = { "en", "el" },
            }

            local ngram_dir = vim.fn.expand("~/ngrams")
            if vim.fn.isdirectory(ngram_dir) == 1 then
                ltex_settings.additionalRules = { languageModel = ngram_dir }
            end

            local servers = {
                vimls = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { "vim" },
                            },
                            workspace = {
                                checkThirdParty = false,
                                library = {
                                    vim.env.VIMRUNTIME,
                                    vim.fn.stdpath("config") .. "/lua",
                                },
                            },
                        },
                    },
                },
                -- rust_analyzer = {},
                clangd = {},
                pyright = {},
                bashls = {},
                texlab = {},
                ltex = {
                    settings = {
                        ltex = ltex_settings,
                    },
                    filetypes = { "latex", "markdown", "text" },
                    cmd_env = {
                        JAVA_OPTS = "-Djdk.xml.totalEntitySizeLimit=0 -Djdk.xml.entityExpansionLimit=0",
                    },
                },
            }

            local flags = {
                debounce_text_changes = 150,
            }

            for server, config in pairs(servers) do
                vim.lsp.config(server, {
                    capabilities = capabilities,
                    on_attach = on_attach,
                    settings = config.settings,
                    flags = flags,
                    filetypes = config.filetypes,
                    cmd_env = config.cmd_env,
                })
                vim.lsp.enable(server)
            end

            vim.keymap.set("n", "<leader>le", vim.diagnostic.open_float, { desc = "Diagnostics: Open float" })
            vim.keymap.set("n", "pd", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Diagnostics: Previous" })
            vim.keymap.set("n", "nd", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Diagnostics: Next" })
        end,
    },
}
