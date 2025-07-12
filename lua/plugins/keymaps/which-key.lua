return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
        triggers = {
            "<auto>",
            mode = "nixsotc",
        },
    },
    plugins = {
        marks = true,
        registers = true,
        spelling = {
            enabled = false,
            suggestions = 3,
        },
        presets = {
            operators = true,
            motions = true,
            text_objects = true,
            windows = false,
            nav = true,
            z = true,
            g = true,
        },
    },
    win = {
        no_overlap = true,
        -- width = 1,
        -- height = { min = 4, max = 25 },
        -- col = 0,
        -- row = math.huge,
        -- border = "none",
        padding = { 1, 2 }, -- [top/bottom, right/left]
        title = true,
        title_pos = "center",
        zindex = 1000,

        bo = {},
        wo = {
            winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
        },
    },
    layout = {
        width = { min = 20 },
        spacing = 3,    -- spacing between columns
    },
    keys = {
        scroll_down = "<c-d>",
        scroll_up = "<c-u>",
    },
    sort = { "local", "order", "group", "alphanum", "mod" },
    expand = 0,
    -- expand = function(node)
    --   return not node.desc -- expand all nodes without a description
    -- end,
    -- Functions/Lua Patterns for formatting the labels
    replace = {
        key = {
            function(key)
                return require("which-key.view").format(key)
            end,
            -- { "<Space>", "SPC" },
        },
        desc = {
            { "<Plug>%(?(.*)%)?", "%1" },
            { "^%+",              "" },
            { "<[cC]md>",         "" },
            { "<[cC][rR]>",       "" },
            { "<[sS]ilent>",      "" },
            { "^lua%s+",          "" },
            { "^call%s+",         "" },
            { "^:%s*",            "" },
        },
    },
    icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
        ellipsis = "…",
        mappings = true,
        rules = {},
        colors = true,
        keys = {
            Up = " ",
            Down = " ",
            Left = " ",
            Right = " ",
            C = "󰘴 ",
            M = "󰘵 ",
            D = "󰘳 ",
            S = "󰘶 ",
            CR = "󰌑 ",
            Esc = "󱊷 ",
            ScrollWheelDown = "󱕐 ",
            ScrollWheelUp = "󱕑 ",
            NL = "󰌑 ",
            BS = "󰁮",
            Space = "󱁐 ",
            Tab = "󰌒 ",
            F1 = "󱊫",
            F2 = "󱊬",
            F3 = "󱊭",
            F4 = "󱊮",
            F5 = "󱊯",
            F6 = "󱊰",
            F7 = "󱊱",
            F8 = "󱊲",
            F9 = "󱊳",
            F10 = "󱊴",
            F11 = "󱊵",
            F12 = "󱊶",
        },
    },
    show_help = true,
    show_keys = true,
    disable = {
        ft = {},
        bt = {},
    },
    debug = false,
}
