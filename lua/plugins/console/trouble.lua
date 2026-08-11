local function trouble(cmd)
    return function()
        require("utils.special_windows").open("trouble", function()
            vim.cmd(cmd)
        end)
    end
end

return {
    "folke/trouble.nvim",
    dependencies = { "rcarriga/nvim-notify" },
    opts = {
        win = {
            position = "bottom",
            relative = "win",
            size = 10,
        },
    },
    cmd = "Trouble",
    keys = {
        {
            "<leader>xD",
            trouble("Trouble diagnostics toggle focus=true"),
            desc = "Diagnostics (Trouble)",
        },
        {
            "<leader>xd",
            trouble("Trouble diagnostics toggle filter.buf=0 focus=true"),
            desc = "Buffer Diagnostics (Trouble)",
        },
        {
            "<leader>xs",
            trouble("Trouble symbols toggle focus=false"),
            desc = "Symbols (Trouble)",
        },
    },
}
