return {
    {
        "rcarriga/nvim-notify",
        config = function()
            local notify = require("notify")
            notify.setup({
                timeout = 1500,
                stages = "fade_in_slide_out",
                fps = 60,
                icons = {
                    DEBUG = "",
                    ERROR = "",
                    INFO = "",
                    TRACE = "✎",
                    WARN = ""
                },
                level = 2, -- 1 = DEBUG, 2 = INFO, 3 = WARN, 4 = ERROR
                time_formats = {
                    notification = "%H:%M",
                    notification_history = "%Y-%m-%dT%H:%M"
                },
                background_colour = "#000000",
                top_down = true,
                render = "default",
            })

            vim.notify = notify
            vim.keymap.set("n", "<Esc>", function()
                if vim.v.hlsearch == 1 then
                    vim.cmd("nohlsearch")
                end

                notify.dismiss({ silent = true, pending = true })
            end, { desc = "Esc: clear highlights and dismiss notifications" })
        end,
    },
}
