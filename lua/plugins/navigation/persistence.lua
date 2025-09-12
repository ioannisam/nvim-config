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
            if not vim.api.nvim_buf_is_valid(buf) then
                return false
            end
            local name = vim.api.nvim_buf_get_name(buf)
            if name == "" then
                return false
            end
            local ok, buftype = pcall(vim.api.nvim_buf_get_option, buf, "buftype")
            local ok2, buflisted = pcall(vim.api.nvim_buf_get_option, buf, "buflisted")
            if not ok or not ok2 then
                return false
            end
            return buflisted and buftype == ""
        end

        local function has_real_buffers()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if is_real_file(buf) then
                    return true
                end
            end
            return false
        end

        vim.api.nvim_create_autocmd("User", {
            pattern = "PersistenceSavePre",
            callback = function()
                local unlisted = {}
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if not is_real_file(buf) then
                        local ft = (pcall(vim.api.nvim_buf_get_option, buf, "filetype") and vim.bo[buf].filetype) or ""
                        local name = vim.api.nvim_buf_get_name(buf)
                        if ft == "undotree" or name:match("__Undotree__") or name:match("^undotree_") then
                            pcall(vim.api.nvim_buf_delete, buf, { force = true })
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

                local session_dir = opts.dir
                local cwd = vim.fn.getcwd()
                local encoded = cwd:gsub(":", "%%"):gsub("/", "%%")
                local session_file = session_dir .. encoded .. ".vim"

                if vim.fn.filereadable(session_file) == 1 and not has_real_buffers() then
                    vim.fn.delete(session_file)
                end
            end,
        })

        vim.api.nvim_create_user_command("PersistenceClear", function()
            local session_dir = opts.dir
            local sessions = vim.fn.globpath(session_dir, "*.vim", false, true)
            if #sessions == 0 then
                vim.notify("No sessions left to clear!", vim.log.levels.INFO, { title = "Persistence " })
                return
            end
            vim.ui.select(sessions, {
                prompt = "Select session to delete (ESC to stop):",
                format_item = function(item) return vim.fn.fnamemodify(item, ":t") end,
            }, function(choice)
                if choice and vim.fn.delete(choice) == 0 then
                    vim.notify("Deleted session: " .. vim.fn.fnamemodify(choice, ":t"), vim.log.levels.INFO, { title = "Persistence " })
                end
            end)
        end, { desc = "Clear multiple sessions interactively" })
    end,
}
