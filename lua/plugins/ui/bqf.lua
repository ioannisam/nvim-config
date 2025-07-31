return {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
        auto_enable = true,
        preview = {
            auto_preview = true,
            win_height = 12,
            delay_syntax = 50,
        },
    },
    config = function()
        local palette = require("catppuccin.palettes").get_palette()

        vim.api.nvim_set_hl(0, "QFTime", { fg = palette.surface2 })

        vim.api.nvim_set_hl(0, "QFInfo", { fg = palette.blue })
        vim.api.nvim_set_hl(0, "QFWarn", { fg = palette.yellow })
        vim.api.nvim_set_hl(0, "QFError", { fg = palette.red })
        vim.api.nvim_set_hl(0, "QFDebug", { fg = palette.teal })
        vim.api.nvim_set_hl(0, "QFTrace", { fg = palette.mauve })

        vim.api.nvim_set_hl(0, "QFIconError", { fg = palette.red })
        vim.api.nvim_set_hl(0, "QFIconWarn", { fg = palette.yellow })
        vim.api.nvim_set_hl(0, "QFIconInfo", { fg = palette.blue })
        vim.api.nvim_set_hl(0, "QFIconDebug", { fg = palette.teal })
        vim.api.nvim_set_hl(0, "QFIconTrace", { fg = palette.mauve })

        vim.cmd([[
            function! SetQFSyntax()
                syntax clear
                
                syntax match qfTime /^\S\+/
                highlight link qfTime QFTime
                
                syntax match qfError /ERROR/ contained
                syntax match qfWarn /WARN/ contained
                syntax match qfInfo /INFO/ contained
                syntax match qfDebug /DEBUG/ contained
                syntax match qfTrace /TRACE/ contained
                
                syntax match qfIconError // contained
                syntax match qfIconWarn // contained
                syntax match qfIconInfo // contained
                syntax match qfIconDebug // contained
                syntax match qfIconTrace /✎/ contained
                
                syntax region qfHeader start=/^/ end=/▶/ contains=qfTime,qfIconError,qfIconWarn,qfIconInfo,qfIconDebug,qfIconTrace,qfError,qfWarn,qfInfo,qfDebug,qfTrace
                
                highlight link qfError QFError
                highlight link qfWarn QFWarn
                highlight link qfInfo QFInfo
                highlight link qfDebug QFDebug
                highlight link qfTrace QFTrace
                
                highlight link qfIconError QFIconError
                highlight link qfIconWarn QFIconWarn
                highlight link qfIconInfo QFIconInfo
                highlight link qfIconDebug QFIconDebug
                highlight link qfIconTrace QFIconTrace
            endfunction
        ]])

        vim.cmd([[
            augroup QuickFixHighlighting
                autocmd!
                autocmd FileType qf call SetQFSyntax()
            augroup END
        ]])
    end,
}
