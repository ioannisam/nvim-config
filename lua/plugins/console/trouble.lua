return {
    "folke/trouble.nvim",
    dependencies = { "rcarriga/nvim-notify" },
    opts = {
        height = 10,
        position = "bottom",
    },
    lazy = false,
    cmd = "Trouble",
    keys = {
        {
            "<leader>xD",
            "<cmd>Trouble diagnostics toggle focus=true<cr>",
            desc = "Diagnostics (Trouble)",
        },
        {
            "<leader>xd",
            "<cmd>Trouble diagnostics toggle filter.buf=0 focus=true<cr>",
            desc = "Buffer Diagnostics (Trouble)",
        },
        {
            "<leader>xs",
            "<cmd>Trouble symbols toggle focus=false<cr>",
            desc = "Symbols (Trouble)",
        },
    },
}
