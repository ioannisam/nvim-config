return {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        local Terminal = require("toggleterm.terminal").Terminal
        local next_id = 0
        local terminals = {}
        local term_names = {}

        local freed_ids = {}
        local function make_term(direction)
            local id
            if #freed_ids > 0 then
                id = table.remove(freed_ids)
            else
                next_id = next_id + 1
                id = next_id
            end
            term_names[id] = nil
            local term = Terminal:new({ count = id, direction = direction })
            terminals[id] = term
            return term, id
        end

        local function refresh_winbar(term)
            if term.window and vim.api.nvim_win_is_valid(term.window) then
                local name = term_names[term.id] or ("Terminal #" .. term.id)
                local fmt = string.format("%%#WinBarTerm#  %s (ID:%d)", name, term.id)
                vim.api.nvim_win_set_option(term.window, "winbar", fmt)
            end
        end

        local function cleanup(id)
            terminals[id] = nil
            term_names[id] = nil
        end

        require("toggleterm").setup({
            size = function(term)
                return math.floor(vim.o.lines*0.3)
            end,
        
            on_open = function(term)
                terminals[term.id] = term
                term.window = vim.api.nvim_get_current_win()
                vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
                vim.defer_fn(function() vim.cmd("stopinsert") end, 20)
                vim.api.nvim_set_hl(0, "WinBarTerm", { fg = "#a3be8c", bold = true })
                refresh_winbar(term)
            end,
            on_exit = function(term)
                if terminals[term.id] then
                    cleanup(term.id)
                    table.insert(freed_ids, term.id)
                    vim.notify("Terminal " .. term.id .. " exited", vim.log.levels.INFO)
                end
            end,
            close_on_exit = true,
            persist_mode = true,
            persist_size = true,
        })

        vim.keymap.set("n", "<leader>tn", function()

            local h_terms = {}
            for _, t in pairs(terminals) do
                if t.direction == "horizontal" then
                    table.insert(h_terms, t)
                end
            end

            for _, t in ipairs(h_terms) do
                if not t:is_open() then
                    t:toggle()
                end
            end

            local t_new, _ = make_term("horizontal")
            t_new:toggle()
        end, { desc = "New horizontal terminal", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>th", function()

            local h_terms = {}
            for _, t in pairs(terminals) do
                if t.direction == "horizontal" then table.insert(h_terms, t) end
            end

            if #h_terms == 0 then
                vim.notify("No horizontal terminals exist", vim.log.levels.INFO)
                return
            end

            local any_open = false
            for _, t in ipairs(h_terms) do
                if t:is_open() then
                    any_open = true
                    break
                end
            end

            for _, t in ipairs(h_terms) do
                if any_open then
                    t:close()
                else
                    t:toggle()
                end
            end
        end, { desc = "Toggle horizontal terminals", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>tr", function()

            local win = vim.api.nvim_get_current_win()
            for id, t in pairs(terminals) do
                if t.window == win then
                    local current_name = term_names[id] or ("Terminal #" .. id)
                    vim.ui.input({ prompt = "New name: ", default = current_name }, function(input)
                        if not input or input == "" then return end
                        term_names[id] = input
                        vim.notify("Renamed to '" .. input .. "'", vim.log.levels.INFO)
                        refresh_winbar(t)
                    end)
                    return
                end
            end

            local items = {}
            for id, t in pairs(terminals) do
                table.insert(items, {
                    id = id,
                    term = t,
                    name = term_names[id] or ("Terminal #" .. id),
                    dir = t.direction,
                })
            end

            if #items == 0 then
                vim.notify("No terminals to rename", vim.log.levels.INFO)
                return
            end

            vim.ui.select(items, {
                prompt = "Rename terminal:",
                format_item = function(x)
                    return string.format("[%d] %s (%s)", x.id, x.name, x.dir)
                end,
            }, function(choice)
                if not choice then return end
                vim.ui.input({ prompt = "New name: ", default = choice.name }, function(input)
                    if not input or input == "" then return end
                    term_names[choice.id] = input
                    vim.notify("Renamed to '" .. input .. "'", vim.log.levels.INFO)
                    refresh_winbar(choice.term)
                end)
            end)
        end, { desc = "Rename terminal", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>td", function()

            local win = vim.api.nvim_get_current_win()
            for id, t in pairs(terminals) do
                if t.window == win then
                    t:shutdown()
                    cleanup(id)
                    table.insert(freed_ids, id)
                    vim.notify("Deleted terminal " .. id, vim.log.levels.INFO)
                    return
                end
            end

            local items = {}
            for id, t in pairs(terminals) do
                table.insert(items, {
                    id = id,
                    term = t,
                    name = term_names[id] or ("Terminal #" .. id),
                    dir = t.direction,
                })
            end

            if #items == 0 then
                vim.notify("No terminals to delete", vim.log.levels.INFO)
                return
            end

            vim.ui.select(items, {
                prompt = "Delete terminal:",
                format_item = function(x) return string.format("[%d] %s (%s)", x.id, x.name, x.dir) end
            }, function(choice)
                if not choice then return end
                choice.term:shutdown()
                cleanup(choice.id)
                table.insert(freed_ids, choice.id)
                vim.notify("Deleted terminal " .. choice.id, vim.log.levels.INFO)
            end)
        end, { desc = "Delete terminal", noremap = true, silent = true })
        
        vim.keymap.set("n", "<leader>tt", function()
            vim.cmd("terminal")
            vim.api.nvim_feedkeys("i", "n", false)
        end, { desc = "Open native terminal", noremap = true, silent = true })

        vim.api.nvim_create_autocmd("TermEnter", {
            pattern = "term://*toggleterm#*",
            callback = function()
                vim.keymap.set("n", "<leader><Up>", function()
                    local win = vim.api.nvim_get_current_win()
                    vim.api.nvim_win_set_height(win, vim.api.nvim_win_get_height(win) + 2)
                end, { buffer = 0, desc = "Increase terminal height", noremap = true, silent = true })

                vim.keymap.set("n", "<leader><Down>", function()
                    local win = vim.api.nvim_get_current_win()
                    vim.api.nvim_win_set_height(win, math.max(vim.api.nvim_win_get_height(win) - 2, 3))
                end, { buffer = 0, desc = "Decrease terminal height", noremap = true, silent = true })
            end,
        })
    end,
}
