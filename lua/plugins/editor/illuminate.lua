return {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        require('illuminate').configure({
            delay = 100,
            under_cursor = true,
            large_file_cutoff = 2000,
            min_count_to_highlight = 1,

            -- No LSP or treesitter on this tier, so both providers have no source.
            providers = {
                'regex',
            },
            filetypes_denylist = require("utils.filetypes").with({ "dirvish" }),
        })
    end
}
