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
        local function trim_comment(line)
            local text = vim.fn.getline(line)

            local comment_patterns = { "//", "--", "#" }
            for _, marker in ipairs(comment_patterns) do
                local pos = text:find("%s*" .. vim.pesc(marker))
                if pos then
                    local trimmed = text:sub(1, pos - 1):gsub("%s+$", "")
                    vim.fn.setline(line, trimmed)
                    return
                end
            end
        end

        vim.keymap.set("n", "gcd", function()
            local line = vim.fn.line(".")
            trim_comment(line)
        end, { desc = "Trim comment from current line" })

        vim.keymap.set("v", "gd", function()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)

            local start_line = vim.fn.line("'<")
            local end_line = vim.fn.line("'>")
            if start_line > end_line then
                start_line, end_line = end_line, start_line
            end

            for line = start_line, end_line do
                trim_comment(line)
            end
        end, { desc = "Trim comments in visual selection" })

    end,
}
