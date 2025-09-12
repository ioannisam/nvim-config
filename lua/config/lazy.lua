local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.notify({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, vim.log.levels.ERROR, { title = "⚡ Lazy" })
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        { import = "plugins.navigation" },
        { import = "plugins.keymaps" },
        { import = "plugins.console" },
        { import = "plugins.editor" },
        { import = "plugins.docs"},
        { import = "plugins.lsp" },
        { import = "plugins.git"},
        { import = "plugins.ai"},
        { import = "plugins.ui" },
    },
    -- other settings
    install = { colorscheme = { "habamax" } },
    checker = { enabled = true },
})

vim.keymap.set("n", "<leader>lt", "<cmd>Lazy<cr>", { desc = "Toggle Lazy" })
vim.keymap.set("n", "<leader>lu", "<cmd>Lazy update<cr>", { desc = "Toggle Lazy" })
vim.api.nvim_create_autocmd("FileType", {
    pattern = "lazy",
    callback = function(event)
        vim.keymap.set("n", "<Esc>", "<cmd>q<cr>", { buffer = event.buf, silent = true })
    end,
})
