return {
    {
        "nvzone/menu",
        event = "VeryLazy",
        dependencies = {
            "nvzone/volt",
            { "nvzone/minty", cmd = { "Shades", "Huefy" } },
        },
        config = function()
            local function line_has_hunk(bufnr, lnum)
                if not lnum or lnum < 1 then
                    return false
                end

                local ok, gs = pcall(require, "gitsigns")
                if not ok or type(gs.get_hunks) ~= "function" then
                    return false
                end

                local ok_hunks, hunks = pcall(gs.get_hunks, bufnr)
                if not ok_hunks or type(hunks) ~= "table" then
                    return false
                end

                for _, hunk in ipairs(hunks) do
                    local added = hunk.added
                    if added and added.start then
                        local first = added.start
                        local last = first + math.max(added.count or 0, 1) - 1
                        if lnum >= first and lnum <= last then
                            return true
                        end
                    end
                end

                return false
            end

            local function menu_for(pos)
                local winid = pos and pos.winid or 0
                if winid == 0 or not vim.api.nvim_win_is_valid(winid) then
                    return "default"
                end

                local buf = vim.api.nvim_win_get_buf(winid)
                local ft = vim.bo[buf].filetype

                if ft == "neo-tree" then
                    return "neo-tree"
                end

                if line_has_hunk(buf, pos.line) then
                    return "gitsigns"
                end

                return "default"
            end

            vim.keymap.set({ "n", "v" }, "<RightMouse>", function()
                local pos = vim.fn.getmousepos()
                if pos.screenrow == 1 then
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<RightMouse>", true, false, true), "n", false)
                    return
                end

                require("menu.utils").delete_old_menus()
                require("menu").open(menu_for(pos), { mouse = true })
            end, { desc = "Open contextual menu (mouse)" })

            vim.keymap.set("n", "<leader>mm", function()
                require("menu.utils").delete_old_menus()
                require("menu").open(menu_for({
                    winid = vim.api.nvim_get_current_win(),
                    line = vim.fn.line("."),
                }))
            end, { desc = "Open contextual menu (keyboard)" })
        end,
    },
}
