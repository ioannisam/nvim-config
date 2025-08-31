return {
    "luukvbaal/statuscol.nvim",
    event = "UIEnter",
    config = function()
        local builtin = require("statuscol.builtin")
        require("statuscol").setup({
            -- order: git signs -> folds -> numbers
            segments = {
                { text = { "%s" },                  click = "v:lua.ScSa" }, -- signs (gitsigns, diagnostics)
                { text = { builtin.foldfunc },      click = "v:lua.ScFa" }, -- folds (/)
                { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" }, -- line numbers
            },
        })
    end,
}
