return {
    "Isrothy/neominimap.nvim",
    version = "v3.x.x",
    lazy = false,
    keys = {
        { "<leader>mt", "<cmd>Neominimap Toggle<cr>",      desc = "Toggle minimap" },
        { "<leader>mf", "<cmd>Neominimap ToggleFocus<cr>", desc = "Switch focus on minimap" },
    },
    init = function()
        vim.g.neominimap = {
            auto_enable = false,
        }
    end,
}
