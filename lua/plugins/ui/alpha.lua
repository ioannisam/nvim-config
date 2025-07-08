return {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VimEnter",
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        dashboard.section.header.val = {
            "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
            "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
            "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
            "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
            "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
            "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
        }

        dashboard.section.buttons.val = {
            dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
            dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
            dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
            dashboard.button("g", "  Find text", ":Telescope live_grep<CR>"),
            dashboard.button("c", "  Config", ":e $MYVIMRC | cd %:p:h <CR>"),
            dashboard.button("q", "  Quit", ":qa<CR>"),
        }
        dashboard.section.buttons.opts.position = "center"

        dashboard.section.footer.val = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return "⚡ Loaded " .. stats.count .. " plugins in " .. ms .. "ms"
        end
        dashboard.section.footer.opts = {
            position = "center",
            hl = "Comment",
        }

        dashboard.config.layout = {
            { type = "padding", val = 10 },
            dashboard.section.header,
            { type = "padding", val = 2 },
            dashboard.section.buttons,
            { type = "padding", val = 0 },
            dashboard.section.footer,
        }

        alpha.setup(dashboard.config)
    end,
}
