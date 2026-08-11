return {
    "tris203/precognition.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        startVisible = false,
        showBlankVirtLine = true,
        highlightColor = { link = "Comment" },
        hints = {
            Caret = { text = "^", prio = 2 },
            Dollar = { text = "$", prio = 1 },
            MatchingPair = { text = "%", prio = 5 },
            Zero = { text = "0", prio = 1 },
            w = { text = "w", prio = 10 },
            b = { text = "b", prio = 9 },
            e = { text = "e", prio = 8 },
            W = { text = "W", prio = 7 },
            B = { text = "B", prio = 6 },
            E = { text = "E", prio = 5 },
        },
        gutterHints = {
            G = { text = "G", prio = 10 },
            gg = { text = "gg", prio = 9 },
            PrevParagraph = { text = "{", prio = 8 },
            NextParagraph = { text = "}", prio = 8 },
        },
        disabled_fts = require("utils.filetypes").with(),
    },
    keys = {
        {
            "<leader>p",
            function()
                local visible = require("precognition").toggle()
                vim.notify(
                    visible and "Precognition enabled" or "Precognition disabled",
                    vim.log.levels.INFO,
                    { title = "Precognition 󰛐" }
                )
            end,
            desc = "Toggle Precognition",
        },
    },
}
