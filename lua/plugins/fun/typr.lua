return {
    "nvzone/typr",
    dependencies = { "nvzone/volt" },
    cmd = { "Typr", "TyprStats" },
    opts = {},
    keys = {
        { "<leader>zt", "<cmd>Typr<cr>", desc = "Typr: Typing practice" },
        { "<leader>zs", "<cmd>TyprStats<cr>", desc = "Typr: Stats dashboard" },
    },
}
