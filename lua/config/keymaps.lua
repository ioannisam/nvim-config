local M = {}
local BLOCKWISE = ''

function M.search_visual_selection()
    local mode = vim.fn.mode()
    if mode ~= 'v' and mode ~= 'V' and mode ~= BLOCKWISE then
        return
    end

    local _, start_row, start_col, _ = unpack(vim.fn.getpos("v"))
    local _, end_row, end_col, _ = unpack(vim.fn.getpos("."))

    if start_row > end_row or (start_row == end_row and start_col > end_col) then
        start_row, end_row = end_row, start_row
        start_col, end_col = end_col, start_col
    end

    local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
    if vim.tbl_isempty(lines) then return end

    local function char_end(line, col)
        if type(line) ~= 'string' or col < 1 or col > #line then
            return col
        end
        return col + vim.str_utf_end(line, col)
    end

    if mode == BLOCKWISE then
        if start_col > end_col then
            start_col, end_col = end_col, start_col
        end
        lines = { string.sub(lines[1], start_col, char_end(lines[1], end_col)) }
    elseif mode ~= 'V' then
        if #lines == 1 then
            lines[1] = string.sub(lines[1], start_col, char_end(lines[1], end_col))
        else
            lines[1] = string.sub(lines[1], start_col)
            lines[#lines] = string.sub(lines[#lines], 1, char_end(lines[#lines], end_col))
        end
    end

    for i, line in ipairs(lines) do
        lines[i] = vim.fn.escape(line, '\\/.*$^~[]')
    end
    local search_text = table.concat(lines, '\\n')
    if search_text == '' then return end

    vim.fn.setreg('/', search_text)
    vim.fn.histadd('search', search_text)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
    pcall(vim.cmd, 'normal! n')
end

vim.keymap.set('v', '*', function()
    require('config.keymaps').search_visual_selection()
end, { noremap = true, silent = true, desc = "Search visual selection" })

vim.keymap.set("n", "<leader>a", "ggVG", { desc = "Select All" })
vim.keymap.set("n", "<leader>w", "<C-w>w", { noremap = true, silent = true, desc = "Switch Window" })

vim.keymap.set("n", "<M-J>", "<Cmd>normal! J<CR>", { silent = true, desc = "Join lines" })
vim.keymap.set("x", "<M-J>", ":<C-u>normal! gvJ<CR>", { silent = true, desc = "Join selected lines" })

vim.keymap.set("n", "<leader>lt", "<cmd>Lazy<cr>", { desc = "Lazy: Open UI" })
vim.keymap.set("n", "<leader>lu", "<cmd>Lazy update<cr>", { desc = "Lazy: Update plugins" })

return M
