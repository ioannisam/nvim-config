return {
	"folke/persistence.nvim",
	lazy = "BufReadPre",
	opts = {
		dir = vim.fn.stdpath("state") .. "/sessions/",
		options = { "buffers", "curdir", "tabpages", "winsize", "folds" },
		need = 1,
	},
    config = function(_, opts)
        local persistence = require("persistence")
        local config = require("persistence.config")

        vim.fn.mkdir(opts.dir, "p")
        config.options = vim.tbl_deep_extend("force", config.options, opts or {})

        local function pre_save()
            local filetype_ignore = {
                "neo-tree",
                "toggleterm",
                "spectre_panel",
                "trouble",
                "undotree",
                "alpha",
                "lazy",
                "fugitive",
            }

            local bufname_ignore = {
                "neo%-tree",
                "^term://",
                "^git://",
            }

            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) then
                    local bufname = vim.api.nvim_buf_get_name(buf)
                    local filetype = vim.api.nvim_buf_get_option(buf, "filetype")

                    local skip = false
                    for _, pattern in ipairs(filetype_ignore) do
                        if filetype:match(pattern) then
                            skip = true
                            break
                        end
                    end

                    if not skip then
                        for _, pattern in ipairs(bufname_ignore) do
                            if bufname:match(pattern) then
                                skip = true
                                break
                            end
                        end
                    end

                    if skip then
                        pcall(vim.api.nvim_buf_delete, buf, { force = true })
                    end
                end
            end
        end

        local original_save = persistence.save
        persistence.save = function()
            pre_save()
            original_save()
        end

        vim.api.nvim_create_user_command("PersistenceClear", function()
            local session_dir = vim.fn.stdpath("state") .. "/sessions/"

            local function get_sessions()
                local files = vim.fn.glob(session_dir .. "*.vim", false, true)
                return vim.tbl_map(function(f)
                    return vim.fn.fnamemodify(f, ":t")
                end, files)
            end

            local sessions = get_sessions()

            if #sessions == 0 then
                vim.notify("No sessions to clear!", vim.log.levels.INFO)
                return
            end

            local function pick_and_delete()
                sessions = get_sessions()
                if #sessions == 0 then
                    vim.notify("All sessions cleared.", vim.log.levels.INFO)
                    return
                end

                vim.ui.select(sessions, { prompt = "Select session to delete (ESC to cancel):" }, function(choice)
                    if choice then
                        local full_path = session_dir .. choice
                        if vim.fn.delete(full_path) == 0 then
                            vim.notify("Deleted session: " .. choice, vim.log.levels.INFO)
                            pick_and_delete()
                        else
                            vim.notify("Failed to delete session: " .. choice, vim.log.levels.ERROR)
                        end
                    end
                end)
            end

            pick_and_delete()
        end, {
                desc = "Clear one or more sessions interactively",
            })

        vim.api.nvim_create_autocmd("VimLeavePre", {
            callback = function()
                persistence.save()
            end,
        })
    end
}
