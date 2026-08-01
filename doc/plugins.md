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
| `DrKJeff16/project.nvim` | navigation | explicit | Project root detection, auto-chdir, and project picker. |
| `famiu/bufdelete.nvim` | navigation | dependency | Safe buffer deletion helper used by buffer workflows. |
| `folke/persistence.nvim` | navigation, ui | explicit+dependency | Session persistence and restore. |
| `folke/which-key.nvim` | keymaps | explicit | Keymap discovery popup and grouping. |
| `kevinhwang91/nvim-bqf` | ui | explicit | Better quickfix list UX. |
| `kevinhwang91/nvim-ufo` | editor | explicit | Folding provider/UX enhancements. |
| `kevinhwang91/promise-async` | editor | dependency | Async helper required by `nvim-ufo`. |
| `kylechui/nvim-surround` | editor | explicit | Surround text objects/actions. |
| `lewis6991/satellite.nvim` | ui | explicit | Scrollbar decorated with diagnostics, git hunks, marks, and search hits. |
| `lukas-reineke/indent-blankline.nvim` | editor | explicit | Indentation guides (ibl). |
| `luukvbaal/statuscol.nvim` | ui | explicit | Custom status/sign/fold column UI. |
| `matze/vim-move` | editor | explicit | Move lines/blocks with keymaps. |
| `monaqa/dial.nvim` | editor | explicit | Increment/decrement extended text objects. |
| `MunifTanjim/nui.nvim` | navigation | dependency | UI primitives used by Neo-tree. |
| `numToStr/Comment.nvim` | editor | explicit | Comment toggling/operator mappings. |
| `nvim-lualine/lualine.nvim` | ui | explicit | Statusline UI. |
| `nvim-lua/plenary.nvim` | editor, navigation, ui | dependency | Lua utility library used by many plugins. |
| `nvim-mini/mini.indentscope` | editor | explicit | Indent scope visualization and motions. |
| `nvim-neo-tree/neo-tree.nvim` | navigation | explicit | File explorer/tree with sources and git status. |
| `nvim-telescope/telescope-fzf-native.nvim` | navigation | dependency | Native FZF sorter for Telescope. |
| `nvim-telescope/telescope.nvim` | editor, navigation, ui | explicit+dependency | Fuzzy finder and picker framework. |
| `nvim-tree/nvim-web-devicons` | navigation, ui | dependency | Filetype icons used by multiple UI plugins. |
| `nvim-treesitter/nvim-treesitter` | editor, navigation | explicit+dependency | Treesitter parser framework and highlighting support. |
| `nvim-treesitter/nvim-treesitter-context` | editor | explicit | Sticky header showing the enclosing scope while scrolling. |
| `nvim-treesitter/nvim-treesitter-textobjects` | editor | explicit | Treesitter textobjects for selection and function/class motions. |
| `rcarriga/nvim-notify` | console, navigation, ui | explicit+dependency | Notification UI backend used directly and by other plugins. |
| `RRethy/vim-illuminate` | editor | explicit | Word/reference illumination under cursor. |
| `ThePrimeagen/harpoon` | navigation, ui | explicit+dependency | Quick file marking/navigation list and picker. |
| `tpope/vim-repeat` | editor | explicit | Extends `.` repeat support for plugin actions. |
| `Wansmer/treesj` | editor | explicit | Split/join syntax nodes with Treesitter. |
| `windwp/nvim-autopairs` | editor | explicit | Auto-insert matching pairs/brackets. |
| `windwp/nvim-ts-autotag` | editor | dependency | Treesitter-based auto-close/rename HTML tags. |

## Categories

Plugin specs live in `lua/plugins/<category>/` and are imported by `lua/config/lazy.lua`.

| Directory | Purpose |
| --- | --- |
| `console` | Integrated terminal. |
| `editor` | Text editing, motions, folding, and buffer-level enhancements. |
| `keymaps` | Which-key configuration and keymap grouping. |
| `navigation` | File tree, pickers, marks, projects, and buffer navigation. |
| `ui` | Colorscheme, statusline, notifications, and scrollbar. |
