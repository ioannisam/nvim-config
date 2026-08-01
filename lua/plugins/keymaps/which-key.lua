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

        local counts_cache = nil
        local function build_counts()
            local leader = vim.g.mapleader or "\\"
            local leader_forms
            if leader == " " then
                leader_forms = { " ", "<Space>" }
            elseif leader == "\t" then
                leader_forms = { "\t", "<Tab>" }
            else
                leader_forms = { leader }
            end

            local lhs_set = {}
            local function collect(maps)
                for _, map in ipairs(maps) do
                    if type(map.lhs) == "string" then
                        lhs_set[map.lhs] = true
                    end
                end
            end

            pcall(function() collect(vim.api.nvim_get_keymap("n")) end)
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) then
                    pcall(function() collect(vim.api.nvim_buf_get_keymap(buf, "n")) end)
                end
            end

            local counts = {}
            for lhs in pairs(lhs_set) do
                for _, form in ipairs(leader_forms) do
                    if vim.startswith(lhs, form) then
                        local rest = lhs:sub(#form + 1)
                        for len = 1, #rest - 1 do
                            local pfx = rest:sub(1, len)
                            counts[pfx] = (counts[pfx] or 0) + 1
                        end
                        break
                    end
                end
            end

            return counts
        end

        vim.api.nvim_create_autocmd({ "BufEnter", "BufDelete", "LspAttach", "LspDetach" }, {
            group = vim.api.nvim_create_augroup("whichkey_group_counts", { clear = true }),
            callback = function()
                counts_cache = nil
            end,
        })

        local function dynamic_group(name, prefix)
            return function()
                counts_cache = counts_cache or build_counts()
                local count = counts_cache[prefix] or 0
                if count == 0 then return name end
                return string.format("%s (+%d)", name, count)
            end
        end

        local buffer_jumps = {}
        for i = 1, 9 do
            buffer_jumps[#buffer_jumps + 1] = { "<leader>" .. i, hidden = true }
        end
        wk.add(buffer_jumps)

        wk.add({
            { "<leader>a", desc = "Select All", icon = "󰢤" },
            { "<leader>w", desc = "Switch Window", icon = "" },
            { "<leader>n", desc = "Toggle Neotree", icon = "󰹩" },
            { "<leader>u", desc = "Toggle UndoTree", icon = "󰣜" },
            { "<leader>o", desc = "Toggle Outline", icon = "󰙴" },

            { "<leader>b", group = dynamic_group("Buffers", "b"), icon = "" },
            { "<leader>h", group = dynamic_group("Harpoon", "h"), icon = "󰛢" },
            { "<leader>t", group = dynamic_group("Terminal", "t"), icon = "" },
            { "<leader>m", group = dynamic_group("Markdown", "m"), icon = "󰘳" },

            { "<leader>g", group = dynamic_group("Git", "g"), icon = "" },
            { "<leader>x", group = dynamic_group("Diagnostics/Lists", "x"), icon = "" },
            { "<leader>l", group = dynamic_group("LSP/Lazy", "l"), icon = "" },

            { "<leader>f", group = dynamic_group("Telescope", "f"), icon = "" },
            { "<leader>y", group = dynamic_group("Yank", "y"), icon = "󰅇" },
            { "<leader>s", group = dynamic_group("Search", "s"), icon = "" },
            { "<leader>sw", group = dynamic_group("Search Word / Selection", "sw"), icon = "" },
            { "<leader>v", group = dynamic_group("Multi-cursor", "v"), icon = "󱢓" },
            
            { "<leader>c", group = dynamic_group("Checklist", "c"), icon = "󰌵" },
        })
    end,
}
