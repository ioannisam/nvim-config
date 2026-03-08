return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
        triggers = {
            { "<auto>", mode = "nxso" },
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
            -- no_overlap = false, -- only works for classic preset
            width = { min = 4, max = 150},
            height = { min = 1, max = 25},
            -- col = 0,
            -- row = math.huge,
            -- border = "none",
            padding = { 1, 1 }, -- [top/bottom, right/left]
            title = true,
            title_pos = "center",
            zindex = 1000,

            bo = {},
            wo = {
                winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
            },
        },
        layout = {
            width = { min = 10, max = 50 },
            -- height = { min = 4, max = math.huge },
            spacing = 3, -- spacing between columns
        },
        keys = {
            scroll_down = "<c-d>",
            scroll_up = "<c-u>",
        },
        sort = { "manual", "local", "group", "mod" },
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
                { "^%+", "" },
                { "<[cC]md>", "" },
                { "<[cC][rR]>", "" },
                { "<[sS]ilent>", "" },
                { "^lua%s+", "" },
                { "^call%s+", "" },
                { "^:%s*", "" },
            },
        },
        icons = {
            breadcrumb = "»",
            separator = "➜",
            group = "",
            ellipsis = "…",
            mappings = true,
            rules = false,
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
    },
    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)

        -- Your original counting logic
        local function count_leader_maps(prefix)
            local leader = vim.g.mapleader or "\\"
            local count = 0
            local seen = {}

            local prefixes = {}
            if leader == " " then
                table.insert(prefixes, " " .. prefix)
                table.insert(prefixes, "<Space>" .. prefix)
            elseif leader == "\t" then
                table.insert(prefixes, "\t" .. prefix)
                table.insert(prefixes, "<Tab>" .. prefix)
            else
                table.insert(prefixes, leader .. prefix)
            end

            local ok, wk_registry = pcall(function() return require("which-key.state").get() end)
            if ok and wk_registry and wk_registry.mappings then
                for _, mapping in ipairs(wk_registry.mappings or {}) do
                    local lhs = mapping.lhs or (mapping[1] and mapping[1].lhs)
                    if lhs and type(lhs) == "string" and not seen[lhs] then
                        for _, pfx in ipairs(prefixes) do
                            if vim.startswith(lhs, pfx) and #lhs > #pfx then
                                seen[lhs] = true
                                count = count + 1
                                break
                            end
                        end
                    end
                end
            end

            local function scan(maps)
                for _, map in ipairs(maps) do
                    if map.lhs and type(map.lhs) == "string" and not seen[map.lhs] then
                        for _, pfx in ipairs(prefixes) do
                            if vim.startswith(map.lhs, pfx) and #map.lhs > #pfx then
                                seen[map.lhs] = true
                                count = count + 1
                                break
                            end
                        end
                    end
                end
            end

            pcall(function() scan(vim.api.nvim_get_keymap("n")) end)
            pcall(function() scan(vim.api.nvim_buf_get_keymap(0, "n")) end)

            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) then
                    pcall(function() scan(vim.api.nvim_buf_get_keymap(buf, "n")) end)
                end
            end

            return count
        end

        -- Factory function that returns a dynamic string function for WhichKey
        local function dynamic_group(name, prefix)
            return function()
                local count = count_leader_maps(prefix)
                if count == 0 then return name end
                return string.format("%s (+%d)", name, count)
            end
        end

        wk.add({
            { "<leader>a", desc = "Select All", icon = "󰢤" },
            { "<leader>w", desc = "Switch Window", icon = "" },
            { "<leader>n", group = dynamic_group("Neotree", "n"), icon = "󰹩" },
            { "<leader>u", desc = "Toggle UndoTree", icon = "󰣜" },

            { "<leader>b", group = dynamic_group("Buffers", "b"), icon = "" },
            { "<leader>h", group = dynamic_group("Harpoon", "h"), icon = "󰛢" },
            { "<leader>t", group = dynamic_group("Terminal", "t"), icon = "" },
            { "<leader>m", group = dynamic_group("Menu/Markdown", "m"), icon = "󰘳" },

            { "<leader>g", group = dynamic_group("Git", "g"), icon = "" },
            { "<leader>d", group = dynamic_group("Debug", "d"), icon = "" },
            { "<leader>x", group = dynamic_group("Diagnostics", "x"), icon = "" },
            { "<leader>l", group = dynamic_group("LSP/Lazy", "l"), icon = "" },

            { "<leader>f", group = dynamic_group("Telescope", "f"), icon = "" },
            { "<leader>s", group = dynamic_group("Search", "s"), icon = "" },
            { "<leader>sw", group = dynamic_group("Search Word / Selection", "sw"), icon = "" },
            { "<leader>v", group = dynamic_group("Multi-cursor", "v"), icon = "󱢓" },
            { "<leader>c", group = dynamic_group("Chat", "c"), icon = "󰌵" },
        })
    end,
}
