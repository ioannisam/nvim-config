return {
    "alec-gibson/nvim-tetris",
    cmd = "Tetris",
    config = function()
        -- The game binds the arrow keys and then <nop>s every letter key,
        -- so hjkl have to be re-bound after its own mappings are installed.
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("tetris_hjkl", { clear = true }),
            pattern = "tetris",
            callback = function(event)
                vim.schedule(function()
                    if not vim.api.nvim_buf_is_valid(event.buf) then
                        return
                    end

                    local moves = {
                        h = "move_left",
                        l = "move_right",
                        j = "soft_drop",
                        k = "rotate",
                    }
                    for lhs, fn in pairs(moves) do
                        vim.keymap.set("n", lhs, function()
                            require("nvim-tetris.game")[fn]()
                        end, {
                            buffer = event.buf,
                            nowait = true,
                            silent = true,
                            desc = "Tetris: " .. fn:gsub("_", " "),
                        })
                    end
                end)
            end,
        })
    end,
    keys = {
        { "<leader>zT", "<cmd>Tetris<cr>", desc = "Tetris: Play" },
    },
}
