return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
        require("nvim-autopairs").setup({
            check_ts = true,

            ignored_next_char = [=[[%w%%%'%[%"%.$]]=],
            enable_moveright = true,
            enable_afterquote = true,
            map_cr = true,
            map_bs = true,

            disable_in_macro = true,
            disable_in_replace_mode = true,
            disable_filetype = { "TelescopePrompt", "spectre_panel" },
        })
    end
}
