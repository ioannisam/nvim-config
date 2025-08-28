return {
    "folke/persistence.nvim",
    lazy = "BufReadPre",
    opts = {
        dir = vim.fn.stdpath("state") .. "/sessions/",
        options = { "curdir", "tabpages", "winsize", "folds" },
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
                "^.*/COMMIT_EDITMSG$",
                "^.*/COMMIT_EDITMSG$",
                "^.*/MERGE_MSG$",
                "^.*/REBASE_EDITMSG$",
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
                return vim.fn.globpath(session_dir, "*.vim", false, true)
            end

            local function pick_and_delete()
                local sessions = get_sessions()
                if #sessions == 0 then
                    vim.notify("No sessions left to clear!", vim.log.levels.INFO)
                    return
                end

                vim.ui.select(sessions, {
                    prompt = "Select session to delete (ESC to stop):",
                    format_item = function(item)
                        return vim.fn.fnamemodify(item, ":t")
                    end,
                }, function(choice)
                        if not choice then
                            return
                        end

                        if vim.fn.delete(choice) == 0 then
                            vim.notify("Deleted session: " .. vim.fn.fnamemodify(choice, ":t"), vim.log.levels.INFO)
                        else
                            vim.notify("Failed to delete: " .. vim.fn.fnamemodify(choice, ":t"), vim.log.levels.ERROR)
                        end

                        vim.schedule(pick_and_delete)
                    end)
            end

            pick_and_delete()
        end, {
                desc = "Clear multiple sessions interactively until none left",
            })

        vim.api.nvim_create_autocmd("VimLeavePre", {
            callback = function()
                persistence.save()
            end,
        })
    end,
}
