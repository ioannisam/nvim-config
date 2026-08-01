return {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        require('illuminate').configure({
            delay = 100,
            under_cursor = true,
            large_file_cutoff = 2000,
            min_count_to_highlight = 1,

            -- No LSP on this tier, so that provider has no source.
            providers = {
                'treesitter',
                'regex',
            },
            filetypes_denylist = require("utils.filetypes").with({ "dirvish" }),
        })
    end
}
