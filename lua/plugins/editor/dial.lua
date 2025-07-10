return {
    "monaqa/dial.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        -- Normal Mode
        {
            "+",
            function()
                require("dial.map").manipulate("increment", "normal")
            end,
            mode = "n",
        },
        {
            "-",
            function()
                require("dial.map").manipulate("decrement", "normal")
            end,
            mode = "n",
        },

        -- Visual Mode
        {
            "+",
            function()
                require("dial.map").manipulate("increment", "visual")
                vim.cmd("normal! gv")
            end,
            mode = "v",
        },
        {
            "-",
            function()
                require("dial.map").manipulate("decrement", "visual")
                vim.cmd("normal! gv")
            end,
            mode = "v",
        },
        -- LIMITATION: from a group of multiple types, it increments/decrements the first
        -- LIMITATION: the entries must be in a different line
    },

    config = function()
        local augend = require("dial.augend")

        require("dial.config").augends:register_group({
            default = {
                augend.integer.alias.decimal_int,
                augend.integer.alias.hex,
                augend.integer.alias.binary,

                augend.constant.alias.bool,
                augend.semver.alias.semver,

                augend.constant.new({
                    elements = { "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten" },
                    word = true,
                    cyclic = false,
                }),

                augend.constant.alias.alpha,
                augend.constant.alias.Alpha,

                augend.date.new({
                    pattern = "%d/%m/%y",
                    default_kind = "day",
                    only_valid = true,
                    word = true,
                }),
                augend.date.new({
                    pattern = "%d/%m/%Y",
                    default_kind = "day",
                    only_valid = true,
                    word = true,
                }),
                augend.date.new({
                    pattern = "%d-%m-%y",
                    default_kind = "day",
                    only_valid = true,
                }),
                augend.date.new({
                    pattern = "%d-%m-%Y",
                    default_kind = "day",
                    only_valid = true,
                    word = true,
                }),

                augend.constant.new({
                    elements = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" },
                    word = true,
                    cyclic = true,
                }),
                augend.constant.new({
                    elements = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" },
                    word = true,
                    cyclic = true,
                }),
            },
        })
    end,
}
