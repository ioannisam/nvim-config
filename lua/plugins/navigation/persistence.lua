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
            return vim.bo[buf].buflisted and vim.bo[buf].buftype == ""
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
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if not is_real_file(buf) then
                        local ft = vim.bo[buf].filetype or ""
                        local name = vim.api.nvim_buf_get_name(buf)
                        if ft == "undotree" or name:match("__Undotree__") or name:match("^undotree_") then
                            pcall(vim.api.nvim_buf_delete, buf, { force = true })
                        end
                    end
                end
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            pattern = "PersistenceSavePost",
            callback = function()
                local session_file = require("persistence").current()

                if vim.fn.filereadable(session_file) == 1 and not has_real_buffers() then
                    vim.fn.delete(session_file)
                end
            end,
        })

        vim.api.nvim_create_user_command("PersistenceClear", function()
            local session_dir = opts.dir
            local sessions = vim.fn.globpath(session_dir, "*.vim", false, true)

            if #sessions == 0 then
                vim.notify("No sessions to clear!", vim.log.levels.INFO, { title = "Persistence " })
                return
            end

            local deleter = require("utils.deleter")
            deleter.multiselect(sessions, {
                prompt = "Select sessions to delete:",
                format_item = function(item)
                    return vim.fn.fnamemodify(item, ":t")
                end,
            }, function(selected)
                    for _, choice in ipairs(selected) do
                        if vim.fn.delete(choice) == 0 then
                            vim.notify("Deleted session: " .. vim.fn.fnamemodify(choice, ":t"), vim.log.levels.INFO, { title = "Persistence " })
                        else
                            vim.notify("Failed to delete session: " .. vim.fn.fnamemodify(choice, ":t"), vim.log.levels.ERROR, { title = "Persistence " })
                        end
                    end
                end)
        end, { desc = "Clear multiple sessions interactively" })
    end,
}
