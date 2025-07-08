return {
    "danilamihailov/beacon.nvim",
    event = "BufReadPost",
    config = function()
        require("beacon").setup({
            enable = true,

            speed = 1,
            width = 30,
            fps = 60,
            winblend = 70,
        })
    end,
}
