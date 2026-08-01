# Plugins

This document lists the plugins of this configuration.

| Name | Category | Type | Description |
| --- | --- | --- | --- |
| `folke/lazy.nvim` | core | core | Plugin manager used to bootstrap and load all plugin specs. |
| `akinsho/bufferline.nvim` | navigation | explicit | Buffer tabline UI and buffer management actions. |
| `akinsho/toggleterm.nvim` | console | explicit | Integrated terminal management with toggles and layouts. |
| `catppuccin/nvim` | ui | explicit | Main colorscheme/theme. |
| `chentoast/marks.nvim` | navigation | explicit | Sign-column visualization and management of vim marks and bookmarks. |
| `christoomey/vim-tmux-navigator` | navigation | explicit | Seamless `<C-h/j/k/l>` movement between Neovim splits and tmux panes. |
| `danilamihailov/beacon.nvim` | ui | explicit | Cursor jump highlight/beacon effect. |
| `DrKJeff16/project.nvim` | navigation | explicit | Project root detection, auto-chdir, and project picker. |
| `famiu/bufdelete.nvim` | navigation | dependency | Safe buffer deletion helper used by buffer workflows. |
| `folke/noice.nvim` | ui | explicit | Enhanced command-line/messages UI. |
| `folke/persistence.nvim` | navigation, ui | explicit+dependency | Session persistence and restore. |
| `folke/todo-comments.nvim` | docs | explicit | Highlight and quickfix integration for TODO/FIX/WARN comments. |
| `folke/trouble.nvim` | console | explicit | Diagnostics/symbols list UI. |
| `folke/which-key.nvim` | keymaps | explicit | Keymap discovery popup and grouping. |
| `gbprod/yanky.nvim` | editor | explicit | Yank ring with history, cycling, and put enhancements. |
| `goolord/alpha-nvim` | ui | explicit | Startup/dashboard screen. |
| `hrsh7th/cmp-buffer` | lsp | dependency | Buffer completion source for `nvim-cmp`. |
| `hrsh7th/cmp-nvim-lsp` | lsp | dependency | LSP completion source for `nvim-cmp`. |
| `hrsh7th/cmp-path` | lsp | dependency | Filesystem path completion source for `nvim-cmp`. |
| `hrsh7th/nvim-cmp` | lsp | explicit | Completion engine. |
| `jake-stewart/multicursor.nvim` | editor | explicit | Multi-cursor editing layer. |
| `jay-babu/mason-null-ls.nvim` | lsp | explicit | Bridges Mason tools into none-ls. |
| `karb94/neoscroll.nvim` | ui | explicit | Smooth scrolling animations. |
| `kevinhwang91/nvim-bqf` | ui | explicit | Better quickfix list UX. |
| `kevinhwang91/nvim-ufo` | editor | explicit | Folding provider/UX enhancements. |
| `kevinhwang91/promise-async` | editor | dependency | Async helper required by `nvim-ufo`. |
| `kylechui/nvim-surround` | editor | explicit | Surround text objects/actions. |
| `L3MON4D3/LuaSnip` | lsp | dependency | Snippet engine for completion/snippets. |
| `lewis6991/gitsigns.nvim` | git | explicit | Git hunk signs and actions. |
| `lewis6991/satellite.nvim` | ui | explicit | Scrollbar decorated with diagnostics, git hunks, marks, and search hits. |
| `lukas-reineke/indent-blankline.nvim` | editor | explicit | Indentation guides (ibl). |
| `luukvbaal/statuscol.nvim` | ui | explicit | Custom status/sign/fold column UI. |
| `mason-org/mason-lspconfig.nvim` | lsp | explicit | Mason + lspconfig bridge for server install/setup. |
| `mason-org/mason.nvim` | console, lsp | explicit+dependency | External tool and LSP server installer manager. |
| `matze/vim-move` | editor | explicit | Move lines/blocks with keymaps. |
| `mbbill/undotree` | editor | explicit | Undo history tree panel. |
| `monaqa/dial.nvim` | editor | explicit | Increment/decrement extended text objects. |
| `MunifTanjim/nui.nvim` | navigation, ui | dependency | UI primitives for plugins like Neo-tree/Noice. |
| `neovim/nvim-lspconfig` | lsp | explicit | LSP client server configurations and attach hooks. |
| `numToStr/Comment.nvim` | editor | explicit | Comment toggling/operator mappings. |
| `nvim-lualine/lualine.nvim` | ui | explicit | Statusline UI. |
| `nvim-lua/plenary.nvim` | ai, docs, editor, git, lsp, navigation, ui | dependency | Lua utility library used by many plugins. |
| `nvim-mini/mini.indentscope` | editor | explicit | Indent scope visualization and motions. |
| `nvim-neo-tree/neo-tree.nvim` | navigation | explicit | File explorer/tree with sources and git status. |
| `nvim-pack/nvim-spectre` | editor | explicit | Project-wide search and replace panel. |
| `nvim-telescope/telescope-fzf-native.nvim` | navigation | dependency | Native FZF sorter for Telescope. |
| `nvim-telescope/telescope.nvim` | editor, navigation, ui | explicit+dependency | Fuzzy finder and picker framework. |
| `nvimtools/none-ls-extras.nvim` | lsp | dependency | Extra none-ls integrations/sources. |
| `nvimtools/none-ls.nvim` | lsp | explicit+dependency | External formatter/linter integrations via LSP-like interface. |
| `nvim-tree/nvim-web-devicons` | navigation, ui | dependency | Filetype icons used by multiple UI plugins. |
| `nvim-treesitter/nvim-treesitter` | editor, navigation | explicit+dependency | Treesitter parser framework and highlighting support. |
| `nvim-treesitter/nvim-treesitter-context` | editor | explicit | Sticky header showing the enclosing scope while scrolling. |
| `nvim-treesitter/nvim-treesitter-textobjects` | editor | explicit | Treesitter textobjects for selection and function/class motions. |
| `nvim-zh/colorful-winsep.nvim` | ui | explicit | Colored window separator styling. |
| `OXY2DEV/markview.nvim` | docs | explicit | Markdown/markup preview tooling. |
| `rafamadriz/friendly-snippets` | lsp | dependency | Snippet collection for LuaSnip/cmp. |
| `ray-x/lsp_signature.nvim` | lsp | explicit | Floating/virtual-text function signature hints while typing. |
| `rcarriga/nvim-notify` | console, navigation, ui | explicit+dependency | Notification UI backend used directly and by other plugins. |
| `RRethy/vim-illuminate` | editor | explicit | Word/reference illumination under cursor. |
| `saadparwaiz1/cmp_luasnip` | lsp | dependency | LuaSnip completion source for `nvim-cmp`. |
| `smiteshp/nvim-navic` | navigation | dependency | LSP context/navigation component used by barbecue. |
| `stevearc/aerial.nvim` | navigation | explicit | Symbol outline sidebar backed by LSP/Treesitter. |
| `stevearc/dressing.nvim` | ui | explicit | Improved `vim.ui` select/input dialogs. |
| `ThePrimeagen/harpoon` | navigation, ui | explicit+dependency | Quick file marking/navigation list and picker. |
| `tpope/vim-fugitive` | git | explicit | Git commands and fugitive workflow. |
| `tpope/vim-repeat` | editor | explicit | Extends `.` repeat support for plugin actions. |
| `utilyre/barbecue.nvim` | navigation | explicit | Breadcrumb/winbar navigation UI. |
| `Wansmer/treesj` | editor | explicit | Split/join syntax nodes with Treesitter. |
| `windwp/nvim-autopairs` | editor | explicit | Auto-insert matching pairs/brackets. |
| `windwp/nvim-ts-autotag` | editor | dependency | Treesitter-based auto-close/rename HTML tags. |

## Categories

Plugin specs live in `lua/plugins/<category>/` and are imported by `lua/config/lazy.lua`.

| Directory | Purpose |
| --- | --- |
| `console` | Terminal and diagnostics panels. |
| `docs` | Markdown rendering and TODO comment tooling. |
| `editor` | Text editing, motions, folding, and buffer-level enhancements. |
| `git` | Git signs and Fugitive. |
| `keymaps` | Which-key configuration and keymap grouping. |
| `lsp` | LSP servers, completion, formatting, and signature help. |
| `navigation` | File tree, pickers, outline, marks, projects, and buffer navigation. |
| `ui` | Colorscheme, statusline, notifications, scrollbars, and visual polish. |
