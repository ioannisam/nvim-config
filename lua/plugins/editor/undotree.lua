return {
    "mbbill/undotree",
    keys = {
        { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle UndoTree" },
    },
    config = function()
        vim.g.undotree_WindowLayout = 2
        vim.g.undotree_SplitWidth = 30
        vim.g.undotree_SetFocusWhenToggle = 1

        vim.o.undofile = true
        vim.o.undodir = vim.fn.stdpath("state") .. "/undo"
        vim.fn.mkdir(vim.o.undodir, "p")
    end,
}
