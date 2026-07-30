local save_dir = vim.fn.expand("~/Pictures/codesnap")

return {
    "mistricky/codesnap.nvim",
    version = "^2",
    cmd = {
        "CodeSnap",
        "CodeSnapSave",
        "CodeSnapSaveAuto",
        "CodeSnapHighlight",
        "CodeSnapSaveHighlight",
        "CodeSnapASCII",
    },
    opts = {
        show_line_number = true,
        show_workspace = false,
        snapshot_config = {
            theme = "candy",
            background = "#00000000",
            watermark = { content = "" },
            window = {
                mac_window_bar = true,
            },
            code_config = {
                font_family = "CaskaydiaCove Nerd Font",
                breadcrumbs = {
                    enable = true,
                },
            },
        },
    },
    config = function(_, opts)
        require("codesnap").setup(opts)

        -- CodeSnap v2 takes the destination as a command argument; there is no
        -- `save_path` option. Wrap it to generate a timestamped filename.
        vim.api.nvim_create_user_command("CodeSnapSaveAuto", function()
            vim.fn.mkdir(save_dir, "p")

            local name = vim.fn.expand("%:t:r")
            if name == "" then
                name = "snippet"
            end

            local target = string.format("%s/%s-%s.png", save_dir, name, os.date("%Y%m%d-%H%M%S"))
            vim.cmd("CodeSnapSave " .. vim.fn.fnameescape(target))
        end, { range = true, desc = "CodeSnap: save the selection to a timestamped file" })
    end,
    keys = {
        -- `:` (not `<Cmd>`) is required: CodeSnap reads the '< and '> marks,
        -- which Vim only sets when leaving visual mode.
        { "<leader>cs", ":<C-u>CodeSnap<cr>", mode = "x", silent = true, desc = "CodeSnap: Copy snapshot" },
        { "<leader>cS", ":<C-u>CodeSnapSaveAuto<cr>", mode = "x", silent = true, desc = "CodeSnap: Save snapshot" },
    },
}
