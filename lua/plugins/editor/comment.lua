return {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        require("Comment").setup({
            padding = true,
            sticky = true,
            ignore = "^$",
            toggler = {
                line = "gcc",
                block = "gbc",
            },
            opleader = {
                line = "gc",
                block = "gb",
            },
            mappings = {
                basic = true,
                extra = true,
            },
        })

        local function comment_markers(bufnr)
            local markers = {}
            local cs = vim.bo[bufnr].commentstring or ""
            local prefix = cs:match("^%s*(.-)%s*%%s")
            if prefix and prefix ~= "" then
                table.insert(markers, prefix)
            end
            return markers
        end

        local function ts_comment_start(bufnr, row, col)
            local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { row, col } })
            if not ok or not node then
                return nil
            end
            while node do
                if node:type():find("comment") then
                    local srow, scol = node:range()
                    if srow == row then
                        return scol
                    end
                    return nil
                end
                node = node:parent()
            end
            return nil
        end

        local function scan_outside_strings(text, marker)
            local quote, escaped = nil, false
            local i = 1
            while i <= #text do
                local ch = text:sub(i, i)
                if escaped then
                    escaped = false
                elseif ch == "\\" then
                    escaped = true
                elseif quote then
                    if ch == quote then
                        quote = nil
                    end
                elseif ch == '"' or ch == "'" then
                    quote = ch
                elseif text:sub(i, i + #marker - 1) == marker then
                    return i - 1
                end
                i = i + 1
            end
            return nil
        end

        local function make_context(bufnr)
            local ctx = { bufnr = bufnr, markers = comment_markers(bufnr), parser = nil }
            local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
            if ok and parser and pcall(parser.parse, parser, true) then
                ctx.parser = parser
            end
            return ctx
        end

        local function comment_start_col(ctx, row, text)
            for _, marker in ipairs(ctx.markers) do
                if ctx.parser then
                    local from = 1
                    while true do
                        local pos = text:find(marker, from, true)
                        if not pos then
                            break
                        end
                        local scol = ts_comment_start(ctx.bufnr, row, pos - 1)
                        if scol then
                            return scol
                        end
                        from = pos + 1
                    end
                else
                    local col = scan_outside_strings(text, marker)
                    if col then
                        return col
                    end
                end
            end
            return nil
        end

        local function trim_comment(ctx, lnum)
            local row = lnum - 1
            local text = vim.api.nvim_buf_get_lines(ctx.bufnr, row, row + 1, false)[1]
            if not text then
                return
            end

            local col = comment_start_col(ctx, row, text)
            if not col then
                return
            end

            local head = text:sub(1, col)
            if head:match("^%s*$") then
                return
            end

            vim.api.nvim_buf_set_lines(ctx.bufnr, row, row + 1, false, { (head:gsub("%s+$", "")) })
        end

        vim.keymap.set("n", "gcd", function()
            local ctx = make_context(vim.api.nvim_get_current_buf())
            trim_comment(ctx, vim.fn.line("."))
        end, { desc = "Trim comment from current line" })

        vim.keymap.set("x", "gd", function()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)

            local ctx = make_context(vim.api.nvim_get_current_buf())
            local start_line = vim.fn.line("'<")
            local end_line = vim.fn.line("'>")
            if start_line > end_line then
                start_line, end_line = end_line, start_line
            end

            for line = start_line, end_line do
                trim_comment(ctx, line)
            end
        end, { desc = "Trim comments in visual selection" })

    end,
}
