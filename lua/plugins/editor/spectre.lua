return {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require("spectre").setup({
            color_devicons = true,
            live_update = false,
            use_trouble_qf = true,
            is_insert_mode = true,
            mapping={
                ['close'] = {
                    map = 'q',
                    cmd = "<cmd>close<CR>",
                    desc = "close spectre"
                },
                ['show_option_menu'] = {
                    map = "<leader>o",
                    cmd = "<cmd>lua require('spectre').show_options()<CR>",
                    desc = "show options"
                },
                ['enter_file'] = {
                    map = "<cr>",
                    cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
                    desc = "open file"
                },
                ['tab'] = {
                    map = '<Tab>',
                    cmd = "<cmd>lua require('spectre').tab()<cr>",
                    desc = 'next query'
                },
                ['shift-tab'] = {
                    map = '<S-Tab>',
                    cmd = "<cmd>lua require('spectre').tab_shift()<cr>",
                    desc = 'previous query'
                },
                ['run_current_replace'] = {
                    map = "<leader>r",
                    cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
                    desc = "replace current line"
                },
                ['run_replace'] = {
                    map = "<leader>R",
                    cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
                    desc = "replace all"
                },
                ['delete_line'] = {
                    map = 'dl',
                    cmd = "<cmd>lua require('spectre.actions').run_delete_line()<CR>",
                    desc = 'delete line',
                },
                ['toggle_line'] = {
                    map = "tl",
                    cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
                    desc = "toggle item"
                },
                ['toggle_ignore_case'] = {
                    map = "ti",
                    cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
                    desc = "toggle ignore case"
                },
                ['toggle_live_update']={
                    map = "tu",
                    cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
                    desc = "update when vim writes to file"
                },
                ['toggle_ignore_hidden'] = {
                    map = "th",
                    cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
                    desc = "toggle search hidden"
                },
                ['send_to_qf'] = {
                    map = "tq",
                    cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
                    desc = "send all items to quickfix"
                },
                ['replace_cmd'] = {
                    map = "<leader>c",
                    cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
                    desc = "input replace command"
                },
                ['resume_last_search'] = {
                    map = "<leader>l",
                    cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
                    desc = "repeat last search"
                },
                ['change_view_mode'] = {
                    map = "<leader>v",
                    cmd = "<cmd>lua require('spectre').change_view()<CR>",
                    desc = "change result view mode"
                },
                ['change_replace_sed'] = {
                    map = "<leader>s",
                    cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
                    desc = "use sed to replace"
                },
                ['change_replace_oxi'] = {
                    map = "<leader>o",
                    cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
                    desc = "use oxi to replace"
                },
                ['select_template'] = {
                    map = '<leader>t',
                    cmd = "<cmd>lua require('spectre.actions').select_template()<CR>",
                    desc = 'pick template',
                },
            },
        })
        vim.keymap.set('n', '<leader>sg', '<cmd>lua require("spectre").toggle()<CR>', {
            desc = "Search Global"
        })
        vim.keymap.set('n', '<leader>swg', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
            desc = "Search current word (global)"
        })
        vim.keymap.set('v', '<leader>swg', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
            desc = "Search current selection (global)"
        })
        vim.keymap.set('n', '<leader>sl', function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].filetype == 'spectre_panel' then
                    vim.api.nvim_win_close(win, true)
                    return
                end
            end

            require("spectre").open_file_search()
        end, { desc = "Search Local (force blank search)" })
        vim.keymap.set('n', '<leader>swl', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
            desc = "Search current word (local)"
        })
        vim.keymap.set('v', '<leader>swl', '<esc><cmd>lua require("spectre").open_file_search()<CR>', {
            desc = "Search current selection (local)"
        })
    end,
}
