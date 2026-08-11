return {
    "matze/vim-move",
    event = "VeryLazy",
    init = function()
        vim.g.move_map_keys = 0
    end,
    config = function()
        -- Normal Mode
        vim.keymap.set("n", "J", "<Plug>MoveLineDown", { desc = "Move: Line down" })
        vim.keymap.set("n", "K", "<Plug>MoveLineUp", { desc = "Move: Line up" })

        -- Visual Mode
        vim.keymap.set("v", "J", "<Plug>MoveBlockDown", { desc = "Move: Selection down" })
        vim.keymap.set("v", "K", "<Plug>MoveBlockUp", { desc = "Move: Selection up" })

        local function release_K(bufnr)
            if vim.api.nvim_buf_is_valid(bufnr) then
                pcall(vim.keymap.del, "n", "K", { buffer = bufnr })
            end
        end

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("move_owns_K", { clear = true }),
            callback = function(args)
                release_K(args.buf)
            end,
        })

        for _, client in ipairs(vim.lsp.get_clients()) do
            for bufnr in pairs(client.attached_buffers or {}) do
                release_K(bufnr)
            end
        end
    end,
}
