return {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
        local mc = require("multicursor-nvim")
        mc.setup()

        vim.keymap.set("n", "<leader>vm", function()
            mc.addCursor()
            vim.notify("Multi-cursor mode activated!", vim.log.levels.INFO, { title = "MultiCursor 󱢓" })
        end, { desc = "Activate multi-cursor mode" })
        vim.keymap.set("x", "<leader>vm", function()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)

            local line = vim.fn.line("'<")
            local col  = vim.fn.col("'<")

            local line_text = vim.fn.getline(line)
            col = math.min(col, #line_text + 1)

            vim.api.nvim_win_set_cursor(0, {line, col - 1})
            mc.addCursor()

            vim.notify("Multi-cursor mode activated!", vim.log.levels.INFO, { title = "MultiCursor 󱢓" })
        end, { desc = "Activate multi-cursor at start of visual selection" })

        mc.addKeymapLayer(function(layerSet)
            layerSet({"n", "x"}, "h", mc.prevCursor)
            layerSet({"n", "x"}, "l", mc.nextCursor)
            layerSet({"n", "x"}, "j", function() mc.lineAddCursor(1) end, { nowait = true, noremap = true, silent = true })
            layerSet({"n", "x"}, "k", function() mc.lineAddCursor(-1) end, { nowait = true, noremap = true, silent = true })
            layerSet({"n", "x"}, "J", function() mc.lineSkipCursor(1) end, { nowait = true, noremap = true, silent = true })
            layerSet({"n", "x"}, "K", function() mc.lineSkipCursor(-1) end, { nowait = true, noremap = true, silent = true })

            layerSet({"n", "x"}, "n", function() mc.matchAddCursor(1) end, { nowait = true, noremap = true, silent = true })
            layerSet({"n", "x"}, "p", function() mc.matchAddCursor(-1) end, { nowait = true, noremap = true, silent = true })
            layerSet({"n", "x"}, "s", function() mc.matchSkipCursor(1) end, { nowait = true, noremap = true, silent = true })
            layerSet({"n", "x"}, "c", mc.deleteCursor, { nowait = true, noremap = true, silent = true })

            layerSet({"n", "x"}, "t", function()
                if mc.cursorsEnabled() then
                    mc.toggleCursor()
                else
                    mc.enableCursors()
                end
            end, { nowait = true, noremap = true, silent = true })
            layerSet("n", "<esc>", function()
                if not mc.cursorsEnabled() then
                    mc.enableCursors()
                    vim.notify("Exit multi-cursor mode.", vim.log.levels.INFO, { title = "MultiCursor 󱢓" })
                else
                    mc.clearCursors()
                    vim.notify("Exit multi-cursor mode.", vim.log.levels.INFO, { title = "MultiCursor 󱢓" })
                end
            end)
        end)

        local hl = vim.api.nvim_set_hl
        hl(0, "MultiCursorCursor", { reverse = true })
        hl(0, "MultiCursorVisual", { link = "Visual" })
        hl(0, "MultiCursorSign", { link = "SignColumn"})
        hl(0, "MultiCursorMatchPreview", { link = "Search" })
        hl(0, "MultiCursorDisabledCursor", { reverse = true })
        hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
        hl(0, "MultiCursorDisabledSign", { link = "SignColumn"})
    end
}
