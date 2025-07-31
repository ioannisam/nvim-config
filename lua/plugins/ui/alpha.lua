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

        vim.api.nvim_create_user_command("AlphaNewFile", function()
            vim.ui.input({ prompt = "New file name: ", default = "untitled" }, function(input)
                if input and input ~= "" then
                    vim.cmd("e " .. vim.fn.fnameescape(input))
                    vim.cmd("startinsert")
                end
            end)
        end, {})

        vim.api.nvim_create_user_command("AlphaRestoreSession", function()
            require("lazy").load({ plugins = { "persistence.nvim" } })

            local cwd = vim.fn.getcwd()
            local encoded = cwd:gsub(":", "%%"):gsub("/", "%%")
            local session_path = vim.fn.stdpath("state") .. "/sessions/" .. encoded .. ".vim"

            if vim.fn.filereadable(session_path) == 1 then
                require("persistence").load()
            else
                vim.notify("No session for this directory. Opening session picker...", vim.log.levels.INFO)
                require("persistence").select()
            end
        end, {})
        dashboard.section.buttons.val = {
            
            dashboard.button("n", "  𝙽̲ew File", ":AlphaNewFile<CR>"),
            dashboard.button("s", "♻️ 𝚂̲ession Restore", ":AlphaRestoreSession<CR>"),
            dashboard.button("r", "  𝚁̲ecent Files", ":Telescope oldfiles<CR>"),
            dashboard.button("f", "  𝙵̲ind File", ":Telescope find_files<CR>"),
            dashboard.button("g", "  𝙶̲rep Text", ":Telescope live_grep<CR>"),
            dashboard.button("c", "  𝙲̲onfiguration", ":e $MYVIMRC | cd %:p:h <CR>"),
            dashboard.button("q", "  𝚀̲uit", ":qa<CR>"),
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

        vim.api.nvim_create_autocmd("BufEnter", {
            group = vim.api.nvim_create_augroup("alpha_no_name_fix", { clear = true }),
            callback = function()
                vim.schedule(function()
                    local buf = vim.api.nvim_get_current_buf()
                    local bufname = vim.api.nvim_buf_get_name(buf)

                    if
                        bufname == ""
                        and not vim.bo[buf].modified
                        and vim.bo[buf].buftype == ""
                        and vim.bo[buf].filetype == ""
                    then
                        local real_buffers = vim.tbl_filter(function(b)
                            return vim.api.nvim_buf_is_valid(b)
                                and vim.bo[b].buflisted
                                and vim.api.nvim_buf_get_name(b) ~= ""
                        end, vim.api.nvim_list_bufs())

                        if #real_buffers == 0 then
                            vim.cmd("bwipeout!")
                            require("alpha").start(true)
                        end
                    end
                end)
            end,
        })
    end,
}
