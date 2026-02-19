return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
        triggers = {
            "<auto>",
            mode = "nixsotc",
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
            height = { min = 4, max = math.huge },
            -- col = 0,
            -- row = math.huge,
            -- border = "none",
            padding = { 0, 1 }, -- [top/bottom, right/left]
            title = true,
            title_pos = "center",
            zindex = 1000,

            bo = {},
            wo = {
                winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
            },
        },
        layout = {
            align = "left",
            height = { min = 4, max = math.huge },
            width = { min = 14, max = 28 },
            spacing = 1, -- spacing between columns
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

        local function count_leader_maps(prefix)
            local leader = vim.g.mapleader or "\\"
            local count = 0
            local seen = {}
            
            -- Build all possible prefix variations
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
            
            -- Count from which-key's own registry (includes lazy-loaded)
            local ok, wk_registry = pcall(function()
                return require("which-key.state").get()
            end)
            
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
            
            -- Fallback: scan registered keymaps
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
            
            -- Also scan all buffers for buffer-local maps (like gitsigns)
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) then
                    pcall(function() scan(vim.api.nvim_buf_get_keymap(buf, "n")) end)
                end
            end
            
            return count
        end

        local function register_groups()
            local function group_with_count(name, prefix)
                local count = count_leader_maps(prefix)
                if count == 0 then
                    return name
                end
                return string.format("%s (+%d)", name, count)
            end

            wk.add({
                { "<leader>a", desc = "Select All", icon = "󰢤", order = 1 },
                { "<leader>w", desc = "Switch Window", icon = "", order = 2 },
                { "<leader>n", group = group_with_count("Neotree", "n"), icon = "󰹩", order = 3 },
                { "<leader>u", desc = "Toggle UndoTree", icon = "󰣜", order = 4 },

                { "<leader>b", group = group_with_count("Buffers", "b"), icon = "", order = 5 },
                { "<leader>h", group = group_with_count("Harpoon", "h"), icon = "󰛢", order = 6 },
                { "<leader>t", group = group_with_count("Terminal", "t"), icon = "", order = 7 },
                { "<leader>m", group = group_with_count("Menu/Markdown", "m"), icon = "󰘳", order = 8 },

                { "<leader>g", group = group_with_count("Git", "g"), icon = "", order = 9 },
                { "<leader>d", group = group_with_count("Debug", "d"), icon = "", order = 10 },
                { "<leader>x", group = group_with_count("Diagnostics", "x"), icon = "", order = 11 },
                { "<leader>l", group = group_with_count("LSP/Lazy", "l"), icon = "", order = 12 },

                { "<leader>f", group = group_with_count("Telescope", "f"), icon = "", order = 13 },
                { "<leader>s", group = group_with_count("Search", "s"), icon = "", order = 14 },
                { "<leader>sw", group = group_with_count("Search Word / Selection", "sw"), icon = "", order = 15 },
                { "<leader>v", group = group_with_count("Multi-cursor", "v"), icon = "󱢓", order = 16 },
                { "<leader>c", group = group_with_count("Chat", "c"), icon = "󰌵", order = 17 },
            })
        end

        vim.schedule(register_groups)
        vim.api.nvim_create_autocmd({ "BufEnter", "LspAttach" }, {
            callback = function()
                vim.schedule(register_groups)
                vim.defer_fn(register_groups, 80)
                vim.defer_fn(register_groups, 220)
            end,
        })
        vim.api.nvim_create_autocmd("User", {
            pattern = { "LazyLoad", "LazyDone", "GitsignsAttach" },
            callback = function()
                vim.schedule(register_groups)
                vim.defer_fn(register_groups, 80)
            end,
        })
    end,
}
