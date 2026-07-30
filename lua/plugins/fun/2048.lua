return {
    "NStefan002/2048.nvim",
    cmd = "Play2048",
    opts = {},
    config = function(_, opts)
        require("2048").setup(opts)

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("2048_arrow_keys", { clear = true }),
            pattern = "2048Game",
            callback = function(event)
                local arrows = {
                    ["<Up>"] = "k",
                    ["<Down>"] = "j",
                    ["<Left>"] = "h",
                    ["<Right>"] = "l",
                }
                for lhs, rhs in pairs(arrows) do
                    vim.keymap.set("n", lhs, rhs, {
                        buffer = event.buf,
                        remap = true,
                        silent = true,
                        desc = "2048: move " .. rhs,
                    })
                end
            end,
        })
    end,
    keys = {
        { "<leader>z2", "<cmd>Play2048<cr>", desc = "2048: Play" },
    },
}
