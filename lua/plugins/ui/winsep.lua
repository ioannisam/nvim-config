return {
    "nvim-zh/colorful-winsep.nvim",
    event = "WinNew",
    config = function()
        require("colorful-winsep").setup({
            smooth = true,
            delay = 10,
            interval = 30,
            no_exec_files = { "TelescopePrompt" },
        })
    end,
}
