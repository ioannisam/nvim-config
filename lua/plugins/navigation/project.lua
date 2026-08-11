return {
    "DrKJeff16/project.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
        require("project").setup({
            lsp = { enabled = true, ignore = {}, no_fallback = false },
            patterns = {
                ".git",
                ".github",
                ".hg",
                ".svn",
                ".nvim.lua",
                ".luarc.json",
                "Makefile",
                "CMakeLists.txt",
                "Cargo.toml",
                "package.json",
                "pyproject.toml",
                "Pipfile",
                "go.mod",
            },
            exclude_dirs = { "~/.cache/*", "/tmp/*" },
            disable_on = {
                bt = { "help", "nofile", "nowrite", "terminal" },
                ft = require("utils.filetypes").with({ "" }),
            },
            silent_chdir = true,
            scope_chdir = "global",
            show_hidden = false,
            telescope = { behavior = "explore", show = "paths", sort = "newest" },
        })

        require("telescope").load_extension("projects")

        vim.keymap.set("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "Telescope: Projects" })
    end,
}
