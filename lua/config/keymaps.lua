local M = {}

function M.search_visual_selection()
    local mode = vim.fn.mode()
    if mode ~= 'v' and mode ~= 'V' and mode ~= '' then
        return
    end

    local _, start_row, start_col, _ = unpack(vim.fn.getpos("v"))
    local _, end_row, end_col, _ = unpack(vim.fn.getpos("."))

    if start_row > end_row or (start_row == end_row and start_col > end_col) then
        start_row, end_row = end_row, start_row
        start_col, end_col = end_col, start_col
    end

    start_col = start_col - 1
    end_col = end_col - 1

    local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
    if vim.tbl_isempty(lines) then return end

    if #lines == 1 then
        lines[1] = string.sub(lines[1], start_col + 1, end_col + 1)
    else
        lines[1] = string.sub(lines[1], start_col + 1)
        lines[#lines] = string.sub(lines[#lines], 1, end_col + 1)
    end

    local search_text = table.concat(lines, "\n")
    search_text = vim.fn.escape(search_text, '\\/.*$^~[]')

    vim.fn.setreg('/', search_text)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
    vim.cmd('normal! n')
end

vim.keymap.set('v', '*', function()
    require('config.keymaps').search_visual_selection()
end, { noremap = true, silent = true, desc = "Search visual selection" })

return M
