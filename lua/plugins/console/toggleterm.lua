return {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        local Terminal = require("toggleterm.terminal").Terminal
        local special_windows = require("utils.special_windows")
        local next_id = 0
        local terminals = {}
        local term_names = {}

        local freed_ids = {}
        local MAX_TERMINALS = 5
        local function make_term(direction)
            local count = 0
            for _, _ in pairs(terminals) do
                count = count + 1
            end
            if count >= MAX_TERMINALS then
                vim.notify(
                    string.format("Terminal limit (%d) reached. Close one to create a new terminal.", MAX_TERMINALS),
                    vim.log.levels.WARN,
                    { title = "ToggleTerm  " }
                )
                return nil
            end

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
                vim.api.nvim_set_option_value("winbar", fmt, { win = term.window })
            end
        end

        local function get_term_window_by_bufnr(bufnr)
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == bufnr then
                    return win
                end
            end
        end

        local function cleanup(id)
            terminals[id] = nil
            term_names[id] = nil
            require("utils.layout").refresh_neotree_buffers()
        end

        local layout = require("utils.layout")
        require("toggleterm").setup({
            size = function()
                return math.floor(vim.o.lines*0.3)
            end,

            on_open = function(term)
                if term and term.bufnr then
                    vim.b[term.bufnr].is_toggleterm = true
                    vim.b[term.bufnr].toggleterm_direction = term.direction
                    vim.b[term.bufnr].toggleterm_id = term.id

                    vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
                end

                layout.confine_terminals_to_main()

                vim.schedule(function()
                    local win = get_term_window_by_bufnr(term.bufnr)
                    if win and vim.api.nvim_win_is_valid(win) then
                        term.window = win
                        vim.api.nvim_set_hl(0, "WinBarTerm", { fg = "#a3be8c", bold = true })
                        refresh_winbar(term)
                    end
                    layout.confine_terminals_to_main()
                    vim.cmd("stopinsert")
                end)
            end,
            on_exit = function(term)
                if term and term.bufnr then
                    pcall(function()
                        if vim.api.nvim_buf_is_valid(term.bufnr) then
                            vim.b[term.bufnr].is_toggleterm = nil
                            vim.b[term.bufnr].toggleterm_direction = nil
                            vim.b[term.bufnr].toggleterm_id = nil
                        end
                    end)
                end

                if terminals[term.id] == term then
                    cleanup(term.id)
                    table.insert(freed_ids, term.id)
                    vim.notify("Terminal " .. term.id .. " exited", vim.log.levels.INFO, { title = "ToggleTerm  " })
                    layout.defer_reflow(50)
                end
            end,
            close_on_exit = true,
            persist_mode = true,
            persist_size = true,
        })

        vim.keymap.set("n", "<leader>tn", function()
            special_windows.open("toggleterm", function()
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
                if not t_new then
                    return
                end

                t_new:toggle()

                vim.defer_fn(function()
                    if t_new.bufnr and vim.api.nvim_buf_is_valid(t_new.bufnr) then
                        vim.b[t_new.bufnr].bufferline_exclude = true
                    end
                    layout.defer_reflow(60)
                end, 20)
            end)
        end, { desc = "New horizontal terminal", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>th", function()
            require("utils.layout").focus_main_win({ silent = true })
            local h_terms = {}
            for _, t in pairs(terminals) do
                if t.direction == "horizontal" then
                    table.insert(h_terms, t)
                end
            end

            if #h_terms == 0 then
                vim.notify("No horizontal terminals exist", vim.log.levels.INFO, { title = "ToggleTerm  " })
                return
            end

            local any_open = false
            for _, t in ipairs(h_terms) do
                if t:is_open() then
                    any_open = true
                    break
                end
            end

            if not any_open then
                special_windows.prepare_for_open("toggleterm")
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
                        if not input or input == "" then
                            return
                        end
                        term_names[id] = input
                        vim.notify("Renamed to '" .. input .. "'", vim.log.levels.INFO, { title = "ToggleTerm  " })
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
                vim.notify("No terminals to rename", vim.log.levels.INFO, { title = "ToggleTerm  " })
                return
            end

            vim.ui.select(items, {
                prompt = "Rename terminal:",
                format_item = function(x)
                    return string.format("[%d] %s (%s)", x.id, x.name, x.dir)
                end,
            }, function(choice)
                if not choice then
                    return
                end
                vim.ui.input({ prompt = "New name: ", default = choice.name }, function(input)
                    if not input or input == "" then
                        return
                    end
                    term_names[choice.id] = input
                    vim.notify("Renamed to '" .. input .. "'", vim.log.levels.INFO, { title = "ToggleTerm  " })
                    refresh_winbar(choice.term)
                end)
            end)
        end, { desc = "Rename terminal", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>td", function()
            local win = vim.api.nvim_get_current_win()
            local found = false

            for id, t in pairs(terminals) do
                if t.window == win then
                    t:shutdown()
                    cleanup(id)
                    table.insert(freed_ids, id)
                    vim.notify("Deleted terminal " .. id, vim.log.levels.INFO, { title = "ToggleTerm  " })
                    found = true
                    break
                end
            end

            if not found then
                vim.notify("Can't delete non terminal window", vim.log.levels.WARN, { title = "ToggleTerm  " })
            end
        end, { desc = "Delete focused terminal", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>tD", function()
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
                vim.notify("No terminals to delete", vim.log.levels.INFO, { title = "ToggleTerm  " })
                return
            end

            local picker = require("utils.picker")
            picker.multiselect(items, {
                prompt = "Select terminals to delete:",
                format_item = function(x)
                    return string.format("[%d] %s (%s)", x.id, x.name, x.dir)
                end,
            }, function(selected)
                    for _, choice in ipairs(selected) do
                        choice.term:shutdown()
                        cleanup(choice.id)
                        table.insert(freed_ids, choice.id)
                        vim.notify("Deleted terminal " .. choice.id, vim.log.levels.INFO, { title = "ToggleTerm  " })
                    end
                end)
        end, { desc = "Delete terminals via picker", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>tt", function()
            special_windows.open("toggleterm", function()
                vim.cmd("terminal")

                local bufnr = vim.api.nvim_get_current_buf()
                vim.b[bufnr].native_term = true
                vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = bufnr, noremap = true, silent = true })

                layout.refresh_neotree_buffers()
            end)
        end, { desc = "Open native terminal", noremap = true, silent = true })

        vim.api.nvim_create_autocmd({ "WinNew", "WinClosed" }, {
            group = vim.api.nvim_create_augroup("toggleterm_reflow_on_layout_change", { clear = true }),
            callback = function()
                if #layout.get_toggleterm_wins() > 0 then
                    layout.defer_reflow(50)
                end
            end,
        })

        vim.api.nvim_create_autocmd("TermEnter", {
            group = vim.api.nvim_create_augroup("toggleterm_resize_keys", { clear = true }),
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
