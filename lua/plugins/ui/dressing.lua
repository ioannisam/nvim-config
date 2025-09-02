return {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
        input = {
            enabled = true,
            border = "rounded",
            relative = "editor",
            prefer_width = 40,
            prompt_align = "center",
            anchor = "NW",
            override = function(conf)
                conf.row = 5
                conf.col = math.floor((vim.o.columns - conf.width) / 2)
                return conf
            end,
            win_options = {
                winblend = 0,
            },
        },
        select = {
            enabled = true,
            backend = { "telescope", "fzf_lua", "builtin" },
        },
    },
}
