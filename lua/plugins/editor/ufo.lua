return {
    "kevinhwang91/nvim-ufo",
    event = "BufReadPost",
    dependencies = {
        "kevinhwang91/promise-async",
        "nvim-treesitter/nvim-treesitter",
    },
    init = function()
        vim.o.foldcolumn = "auto:1"
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
        vim.o.foldmethod = "manual"

        vim.opt.fillchars = vim.opt.fillchars
        + { foldopen = "", foldclose = "", fold = " ", foldsep = " " }
    end,
    config = function()
        local handler = function(virtText, lnum, endLnum, width, truncate)
            local newVirtText = {}
            local suffix = (' 󰁂 %d '):format(endLnum - lnum)
            local sufWidth = vim.fn.strdisplaywidth(suffix)
            local targetWidth = width - sufWidth
            local curWidth = 0

            for _, chunk in ipairs(virtText) do
                local chunkText, hlGroup = chunk[1], chunk[2]
                local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                if targetWidth > curWidth + chunkWidth then
                    table.insert(newVirtText, chunk)
                else
                    chunkText = truncate(chunkText, targetWidth - curWidth)
                    table.insert(newVirtText, { chunkText, hlGroup })
                    chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if curWidth + chunkWidth < targetWidth then
                        suffix = suffix .. string.rep(' ', targetWidth - curWidth - chunkWidth)
                    end
                    break
                end
                curWidth = curWidth + chunkWidth
            end
            table.insert(newVirtText, { suffix, "MoreMsg" })
            return newVirtText
        end

        require("ufo").setup({
            fold_virt_text_handler = handler,
            provider_selector = function(_, filetype, _)
                return { "treesitter", "indent" }
            end,
            open_fold_hl_timeout = 0,
        })

        vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds (ufo)" })
        vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds (ufo)" })
    end,
}
