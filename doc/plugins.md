# Plugins

This document lists the plugins of this configuration.

| Name | Category | Type | Description |
| --- | --- | --- | --- |
| `folke/lazy.nvim` | core | core | Plugin manager used to bootstrap and load all plugin specs. |
| `akinsho/bufferline.nvim` | navigation | explicit | Buffer tabline UI and buffer management actions. |
| `akinsho/toggleterm.nvim` | console | explicit | Integrated terminal management with toggles and layouts. |
| `catppuccin/nvim` | ui | explicit | Main colorscheme/theme. |
| `christoomey/vim-tmux-navigator` | navigation | explicit | Seamless `<C-h/j/k/l>` movement between Neovim splits and tmux panes. |
| `famiu/bufdelete.nvim` | navigation | dependency | Safe buffer deletion helper used by buffer workflows. |
| `folke/which-key.nvim` | keymaps | explicit | Keymap discovery popup and grouping. |
| `lukas-reineke/indent-blankline.nvim` | editor | explicit | Indentation guides (ibl). |
| `matze/vim-move` | editor | explicit | Move lines/blocks with keymaps. |
| `MunifTanjim/nui.nvim` | navigation | dependency | UI primitives used by Neo-tree. |
| `numToStr/Comment.nvim` | editor | explicit | Comment toggling/operator mappings. |
| `nvim-lualine/lualine.nvim` | ui | explicit | Statusline UI. |
| `nvim-mini/mini.indentscope` | editor | explicit | Indent scope visualization and motions. |
| `nvim-lua/plenary.nvim` | navigation | dependency | Lua utility library used by many plugins. |
| `nvim-neo-tree/neo-tree.nvim` | navigation | explicit | File explorer/tree with sources and git status. |
| `nvim-telescope/telescope-fzf-native.nvim` | navigation | dependency | Native FZF sorter for Telescope. |
| `nvim-telescope/telescope.nvim` | editor, navigation, ui | explicit+dependency | Fuzzy finder and picker framework. |
| `nvim-tree/nvim-web-devicons` | navigation, ui | dependency | Filetype icons used by multiple UI plugins. |
| `RRethy/vim-illuminate` | editor | explicit | Word/reference illumination under cursor. |

## Categories

Plugin specs live in `lua/plugins/<category>/` and are imported by `lua/config/lazy.lua`.

| Directory | Purpose |
| --- | --- |
| `console` | Integrated terminal. |
| `editor` | Comments, line movement, and indentation guides. |
| `keymaps` | Which-key configuration and keymap grouping. |
| `navigation` | File tree, fuzzy finder, and buffer tabline. |
| `ui` | Colorscheme and statusline. |
