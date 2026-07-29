return {
    "mbbill/undotree",
    keys = {
        {
            "<leader>u",
            function()
                local special_windows = require("utils.special_windows")
                if special_windows.is_open("undotree") then
                    vim.cmd("UndotreeToggle")
                    return
                end
                special_windows.prepare_for_open("undotree")
                vim.cmd("UndotreeToggle")
            end,
            desc = "Toggle UndoTree",
        },
    },
    config = function()
        vim.g.undotree_WindowLayout = 2
        vim.g.undotree_SplitWidth = 30
        vim.g.undotree_SetFocusWhenToggle = 1
    end,
}
