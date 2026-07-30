return {
    "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
    opts = {
        bind = true,
        hint_enable = true,
        hint_prefix = "󰊕 ",
        floating_window = true,
        floating_window_above_cur_line = true,
        fix_pos = false,
        close_timeout = 4000,
        doc_lines = 5,
        max_height = 12,
        max_width = 80,
        wrap = true,
        toggle_key = "<M-s>",
        toggle_key_flip_floatwin_setting = true,
        select_signature_key = "<M-j>",
        handler_opts = {
            border = "rounded",
        },
    },
}
