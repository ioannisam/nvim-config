return {
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = "VeryLazy",
        config = function()
            local hooks = require("ibl.hooks")

            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "IblIndent", { fg = "#575268", nocombine = true })
                vim.api.nvim_set_hl(0, "IblScope",  { fg = "#8aadf4", nocombine = true })
            end)

            require("ibl").setup({
                indent = {
                    char = "│",
                    highlight = "IblIndent",
                    priority = 0,
                    smart_indent_cap = false
                },

                scope  = {
                    enabled    = false, -- mini.indentscope
                    show_start = false,
                    show_end   = false,
                    highlight  = "IblScope",
                },

                whitespace = {
                    remove_blankline_trail = true,
                },

                exclude = {
                    filetypes = require("utils.filetypes").with({ "terminal" }),
                    buftypes = { "terminal", "nofile" },
                },
            })
        end
    },
    {
        "nvim-mini/mini.indentscope",
        version = false,
        event = "VeryLazy",
        config = function()
            local mini = require("mini.indentscope")

            mini.setup({
                symbol = "│",
                options = {
                    try_as_border = false,
                    indent_at_cursor = false,
                    border = "both",
                },
                draw = {
                    delay = 30,
                    priority = 10,
                    animation = mini.gen_animation.none(),
                    -- animation = mini.gen_animation.quadratic({ duration = 8 }),
                },
                mappings = {
                    goto_top = '[i',
                    goto_bottom = ']i',
                }
            })

            vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#8aadf4", nocombine = true })
        end,
    },
}
