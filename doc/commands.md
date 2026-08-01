# Commands

This document lists command-line commands (`:`) available in this Neovim configuration.

## Plugin Commands Used In This Setup

These commands are explicitly enabled by plugin config, keymaps, or plugin `cmd` specs.

| Command | Source | Type | Description |
| --- | --- | --- | --- |
| `:Lazy` | `folke/lazy.nvim` | plugin | Open Lazy UI. |
| `:Lazy update` | `folke/lazy.nvim` | plugin | Update plugins. |
| `:Neotree toggle` | `nvim-neo-tree/neo-tree.nvim` | plugin | Toggle Neo-tree. |
| `:Telescope find_files` | `nvim-telescope/telescope.nvim` | plugin | Open find files picker. |
| `:Telescope live_grep` | `nvim-telescope/telescope.nvim` | plugin | Open live grep picker. |
| `:Telescope oldfiles` | `nvim-telescope/telescope.nvim` | plugin | Open recent files picker. |
| `:BufferLineCycleNext` | `akinsho/bufferline.nvim` | plugin | Go to next buffer. |
| `:BufferLineCyclePrev` | `akinsho/bufferline.nvim` | plugin | Go to previous buffer. |
| `:BufferLineMoveNext` | `akinsho/bufferline.nvim` | plugin | Move current buffer right. |
| `:BufferLineMovePrev` | `akinsho/bufferline.nvim` | plugin | Move current buffer left. |
| `:BufferLineTogglePin` | `akinsho/bufferline.nvim` | plugin | Pin/unpin current buffer. |

## Native Neovim Commands

Core built-in commands that are frequently useful in this setup.

| Command | Type | Description |
| --- | --- | --- |
| `:e {file}` | native | Open/edit file. |
| `:w` | native | Save current buffer. |
| `:wa` | native | Save all buffers. |
| `:q` | native | Quit current window. |
| `:qa` | native | Quit all windows. |
| `:wq` | native | Save and quit. |
| `:bd` | native | Delete current buffer. |
| `:buffers` | native | List buffers. |
| `:noh` or `:nohlsearch` | native | Clear search highlighting. |
| `:copen` | native | Open quickfix list. |
| `:cclose` | native | Close quickfix list. |
| `:lopen` | native | Open location list. |
| `:lclose` | native | Close location list. |
| `:checkhealth` | native | Run health diagnostics. |
| `:help {topic}` | native | Open help docs. |
| `:terminal` | native | Open terminal buffer. |

## Notes

- This list focuses on commands explicitly wired by this configuration and key plugins in use.
- Some plugins expose many additional subcommands; those are documented in each plugin's `:help` pages.
