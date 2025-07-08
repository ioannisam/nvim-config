return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        {
            "windwp/nvim-ts-autotag",
            event = "InsertEnter",
            config = true,
        },
        {
            "nvim-treesitter/playground",
            cmd = "TSPlaygroundToggle",
        },
    },
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = { "lua", "vim", "bash", "c", "cpp", "rust", "python", "json", "markdown", --[["latex"]] },
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = {
                enable = true,
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<leader>z",
                    node_incremental = "<leader>x",
                    node_decremental = "<leader>c",
                    scope_incremental = nil,
                },
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        ["]m"] = "@function.outer",
                        ["]]"] = "@class.outer",
                    },
                    goto_previous_start = {
                        ["[m"] = "@function.outer",
                        ["[["] = "@class.outer",
                    },
                },
            },
            autotag = {
                enable = true,
            }
        })
    end,
}
