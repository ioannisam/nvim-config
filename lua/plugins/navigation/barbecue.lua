return {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
        "smiteshp/nvim-navic",
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local ok, barbecue = pcall(require, "barbecue")
        if not ok then return end

        barbecue.setup({
            theme = "catppuccin",
            attach_navic = true,
            show_dirname = false,
            show_basename = false,
            show_modified = false,
            symbols = {
                modified = "●",
                ellipsis = "…",
                separator = ">",
            },
        })
    end,
}
