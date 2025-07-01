require("config.options")
require("config.lazy")

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 0 then  -- only open if no file was specified
            require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
        end
    end,
})
