local ensure_installed = {
    "lua",
    "vim",
    "vimdoc",
    "query",
    "bash",
    "c",
    "cpp",
    "rust",
    "python",
    "json",
    "markdown",
    "markdown_inline",
}

local selection_stack = {}

local function set_visual(srow, scol, erow, ecol)
    if vim.fn.mode():match("[vV\22]") then
        vim.cmd([[execute "normal! \<Esc>"]])
    end

    if ecol == 0 and erow > srow then
        erow = erow - 1
        ecol = #vim.fn.getline(erow + 1)
    end

    vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
    vim.cmd("normal! v")
    vim.api.nvim_win_set_cursor(0, { erow + 1, math.max(ecol - 1, 0) })
end

local function init_selection()
    local node = vim.treesitter.get_node()
    if not node then
        return
    end
    selection_stack = { node }
    set_visual(node:range())
end

local function node_incremental()
    local node = selection_stack[#selection_stack]
    if not node then
        init_selection()
        return
    end

    local parent = node:parent()
    while parent and vim.deep_equal({ parent:range() }, { node:range() }) do
        parent = parent:parent()
    end

    if parent then
        table.insert(selection_stack, parent)
        node = parent
    end
    set_visual(node:range())
end

local function node_decremental()
    if #selection_stack > 1 then
        table.remove(selection_stack)
    end
    local node = selection_stack[#selection_stack]
    if node then
        set_visual(node:range())
    end
end

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            {
                "windwp/nvim-ts-autotag",
                event = "InsertEnter",
                config = function()
                    require("nvim-ts-autotag").setup()
                end,
            },
        },
        config = function()
            local ts = require("nvim-treesitter")
            ts.setup({})

            local missing = {}
            local installed = ts.get_installed("parsers")
            for _, lang in ipairs(ensure_installed) do
                if not vim.list_contains(installed, lang) then
                    table.insert(missing, lang)
                end
            end

            if #missing > 0 then
                if vim.fn.executable("tree-sitter") == 1 then
                    ts.install(missing)
                else
                    vim.notify(
                        ("Missing %d parser(s): %s\nInstall the tree-sitter CLI, then :TSUpdate")
                            :format(#missing, table.concat(missing, ", ")),
                        vim.log.levels.WARN,
                        { title = "Treesitter " }
                    )
                end
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("treesitter_enable", { clear = true }),
                callback = function(args)
                    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
                    if not lang or not pcall(vim.treesitter.language.add, lang) then
                        return
                    end

                    if not pcall(vim.treesitter.start, args.buf, lang) then
                        return
                    end

                    if vim.treesitter.query.get(lang, "indents") then
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })

            vim.keymap.set("n", "<C-Space>", init_selection, { desc = "Treesitter: Start selection" })
            vim.keymap.set("x", "<C-Space>", node_incremental, { desc = "Treesitter: Expand selection" })
            vim.keymap.set("x", "<BS>", node_decremental, { desc = "Treesitter: Shrink selection" })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = { lookahead = true },
                move = { set_jumps = true },
            })

            local select = require("nvim-treesitter-textobjects.select")
            local move = require("nvim-treesitter-textobjects.move")

            local textobjects = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
            }
            for lhs, capture in pairs(textobjects) do
                vim.keymap.set({ "x", "o" }, lhs, function()
                    select.select_textobject(capture, "textobjects")
                end, { desc = "Treesitter: Select " .. capture })
            end

            local moves = {
                { "]m", move.goto_next_start, "@function.outer" },
                { "]]", move.goto_next_start, "@class.outer" },
                { "[m", move.goto_previous_start, "@function.outer" },
                { "[[", move.goto_previous_start, "@class.outer" },
            }
            for _, spec in ipairs(moves) do
                local lhs, fn, capture = spec[1], spec[2], spec[3]
                vim.keymap.set({ "n", "x", "o" }, lhs, function()
                    fn(capture, "textobjects")
                end, { desc = "Treesitter: Move to " .. capture })
            end
        end,
    },
}
