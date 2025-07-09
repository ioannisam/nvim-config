return {
    {
        "williamboman/mason-lspconfig.nvim",
        opts = {
            ensure_installed = {
                "vimls",
                "lua_ls",
                "bashls",
                "rust_analyzer",
                "clangd",
                "texlab",
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            if cmp_nvim_lsp_ok then
                capabilities = cmp_nvim_lsp.default_capabilities()
            end

            local on_attach = function(_, bufnr)
                local bufmap = function(mode, lhs, rhs)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
                end

                bufmap("n", "gd", vim.lsp.buf.definition)
                bufmap("n", "K", vim.lsp.buf.hover)
                bufmap("n", "<leader>rn", vim.lsp.buf.rename)
                bufmap("n", "<leader>ca", vim.lsp.buf.code_action)
                bufmap("n", "gr", vim.lsp.buf.references)
            end

            local servers = {
                vimls = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = { globals = { "vim" } },
                            workspace = { checkThirdParty = false },
                        },
                    },
                },
                rust_analyzer = {},
                clangd = {},
                texlab = {},
                bashls = {},
            }

            local flags = {
                debounce_text_changes = 150,
            }

            for server, config in pairs(servers) do
                lspconfig[server].setup({
                    capabilities = capabilities,
                    on_attach = on_attach,
                    settings = config.settings,
                    flags = flags,
                })
            end

            vim.keymap.set("n", "<leader>xx", vim.diagnostic.setqflist)
            vim.keymap.set("n", "<leader>xX", vim.diagnostic.setloclist)
            vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
            vim.keymap.set("n", "pd", vim.diagnostic.goto_prev)
            vim.keymap.set("n", "nd", vim.diagnostic.goto_next)
        end,
    }
}
