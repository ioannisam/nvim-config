return {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
        dir = vim.fn.stdpath("state") .. "/sessions/",
        options = { "buffers", "curdir", "tabpages", "winsize", "folds" },
        branch = true,
    },
    config = function(_, opts)
        require("persistence").setup(opts)
        vim.opt.sessionoptions = opts.options

        local function is_real_file(buf)
            return vim.api.nvim_buf_is_loaded(buf)
                and vim.bo[buf].buflisted
                and vim.bo[buf].buftype == ""
                and vim.api.nvim_buf_get_name(buf) ~= ""
        end

        vim.api.nvim_create_autocmd("User", {
            pattern = "PersistenceSavePre",
            callback = function()
                local unlisted = {}
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if not is_real_file(buf) then
                        local ft = vim.bo[buf].filetype
                        local name = vim.api.nvim_buf_get_name(buf)
                        if ft == "undotree" or name:match("__Undotree__") or name:match("^undotree_") then
                            pcall(vim.api.nvim_buf_delete, buf, { force = true })
                        elseif vim.bo[buf].buflisted then
                            vim.bo[buf].buflisted = false
                            table.insert(unlisted, buf)
                        end
                    end
                end
                vim.g._persistence_unlisted_restore = unlisted
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            pattern = "PersistenceSavePost",
            callback = function()
                local list = vim.g._persistence_unlisted_restore or {}
                for _, buf in ipairs(list) do
                    if vim.api.nvim_buf_is_valid(buf) then
                        vim.bo[buf].buflisted = true
                    end
                end
                vim.g._persistence_unlisted_restore = nil
            end,
        })

        vim.api.nvim_create_user_command("PersistenceClear", function()
            local session_dir = opts.dir
            local sessions = vim.fn.globpath(session_dir, "*.vim", false, true)
            if #sessions == 0 then
                vim.notify("No sessions left to clear!", vim.log.levels.INFO)
                return
            end
            vim.ui.select(sessions, {
                prompt = "Select session to delete (ESC to stop):",
                format_item = function(item) return vim.fn.fnamemodify(item, ":t") end,
            }, function(choice)
                if choice and vim.fn.delete(choice) == 0 then
                    vim.notify("Deleted session: " .. vim.fn.fnamemodify(choice, ":t"), vim.log.levels.INFO)
                end
            end)
        end, { desc = "Clear multiple sessions interactively" })
    end,
}
