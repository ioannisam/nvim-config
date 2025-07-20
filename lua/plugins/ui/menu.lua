return {
    {
        "nvzone/menu",
        event = "VeryLazy",
        dependencies = {
            "nvzone/volt",
            { "nvzone/minty", cmd = { "Shades", "Huefy" } },
        },
        config = function()
            local function get_contextual_menu()
                local winid = vim.fn.getmousepos().winid
                local buf = vim.api.nvim_win_get_buf(winid)
                local ft = vim.bo[buf].filetype

                local menu_name = ({
                    ["neo-tree"] = "neo-tree",
                    ["gitsigns"] = "gitsigns",
                })[ft] or "default"

                return menu_name
            end

            vim.keymap.set({ "n","v" }, "<RightMouse>", function()
                require("menu.utils").delete_old_menus()
                vim.cmd.exec('"normal! \\<RightMouse>"')
                require("menu").open(get_contextual_menu(), { mouse = true })
            end, { desc = "Open contextual menu (mouse)" })

            vim.keymap.set("n", "<leader>mm", function()
                require("menu.utils").delete_old_menus()
                require("menu").open(get_contextual_menu())
            end, { desc = "Open contextual menu (keyboard)" })

        end,
    },
}
