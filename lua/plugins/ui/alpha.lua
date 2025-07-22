-- alpha-nvim setup (fixed)
return {
    "goolord/alpha-nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "folke/persistence.nvim",
    },
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
            dashboard.button("n", "  New File", ":ene <BAR> startinsert <CR>"),
            dashboard.button("s", "♻️ Restore Session", function()
                require("lazy").load({ plugins = { "persistence.nvim" } })

                local cwd = vim.fn.getcwd()
                local encoded = cwd:gsub(":", "%%")
                    :gsub("/", "%%")
                local session_path = vim.fn.stdpath("state") .. "/sessions/" .. encoded .. ".vim"

                if vim.fn.filereadable(session_path) == 1 then
                    require("persistence").load()
                else
                    vim.notify("No session for this directory. Opening session picker...", vim.log.levels.INFO)
                    require("persistence").select()
                end
            end),
            dashboard.button("r", "  Recent Files", ":Telescope oldfiles<CR>"),
            dashboard.button("f", "  Find File", ":Telescope find_files<CR>"),
            dashboard.button("g", "  Grep Text", ":Telescope live_grep<CR>"),
            dashboard.button("c", "  Configuration", ":e $MYVIMRC | cd %:p:h <CR>"),
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
            { type = "padding", val = 8 },
            dashboard.section.header,
            { type = "padding", val = 2 },
            dashboard.section.buttons,
            { type = "padding", val = 0 },
            dashboard.section.footer,
        }

        alpha.setup(dashboard.config)
    end,
}
