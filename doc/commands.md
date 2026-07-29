# Commands

This document lists command-line commands (`:`) available in this Neovim configuration.

## Custom User Commands

These are defined directly in this config via `vim.api.nvim_create_user_command`.

| Command | Source | Type | Description |
| --- | --- | --- | --- |
| `:AlphaNewFile` | `goolord/alpha-nvim` + local config | custom | Prompt for a new file and open it. |
| `:AlphaRestoreSession` | `goolord/alpha-nvim` + `folke/persistence.nvim` | custom | Restore session for current cwd (or open session picker fallback). |
| `:PersistenceClear` | `folke/persistence.nvim` + local config | custom | Interactively delete saved sessions. |
| `:CopilotAuth` | `zbirenbaum/copilot.lua` + local config | custom | Start GitHub Copilot auth flow. |

## Plugin Commands Used In This Setup

These commands are explicitly enabled by plugin config, keymaps, or plugin `cmd` specs.

| Command | Source | Type | Description |
| --- | --- | --- | --- |
| `:Lazy` | `folke/lazy.nvim` | plugin | Open Lazy UI. |
| `:Lazy update` | `folke/lazy.nvim` | plugin | Update plugins. |
| `:Trouble` | `folke/trouble.nvim` | plugin | Open Trouble interface. |
| `:Trouble diagnostics toggle` | `folke/trouble.nvim` | plugin | Toggle diagnostics view. |
| `:Trouble diagnostics toggle filter.buf=0` | `folke/trouble.nvim` | plugin | Toggle buffer-local diagnostics view. |
| `:Trouble symbols toggle` | `folke/trouble.nvim` | plugin | Toggle symbols view. |
| `:LazyGit` | `kdheepak/lazygit.nvim` | plugin | Open Lazygit. |
| `:LazyGitConfig` | `kdheepak/lazygit.nvim` | plugin | Open Lazygit config. |
| `:LazyGitCurrentFile` | `kdheepak/lazygit.nvim` | plugin | Lazygit scoped to current file. |
| `:LazyGitFilter` | `kdheepak/lazygit.nvim` | plugin | Lazygit with filter. |
| `:LazyGitFilterCurrentFile` | `kdheepak/lazygit.nvim` | plugin | Lazygit filter scoped to current file. |
| `:Neotree toggle` | `nvim-neo-tree/neo-tree.nvim` | plugin | Toggle Neo-tree. |
| `:Neominimap Toggle` | `Isrothy/neominimap.nvim` | plugin | Toggle minimap. |
| `:Neominimap ToggleFocus` | `Isrothy/neominimap.nvim` | plugin | Focus/unfocus minimap. |
| `:TSUpdate` | `nvim-treesitter/nvim-treesitter` | plugin | Install/update the configured Treesitter parsers. |
| `:TSInstall {lang}` | `nvim-treesitter/nvim-treesitter` | plugin | Install a single Treesitter parser. |
| `:TodoQuickFix` | `folke/todo-comments.nvim` | plugin | Send TODO items to quickfix list. |
| `:UndotreeToggle` | `mbbill/undotree` | plugin | Toggle undo tree window. |
| `:Markview Toggle` | `OXY2DEV/markview.nvim` | plugin | Toggle Markview preview. |
| `:Telescope find_files` | `nvim-telescope/telescope.nvim` | plugin | Open find files picker. |
| `:Telescope live_grep` | `nvim-telescope/telescope.nvim` | plugin | Open live grep picker. |
| `:Telescope oldfiles` | `nvim-telescope/telescope.nvim` | plugin | Open recent files picker. |
| `:BufferLineCycleNext` | `akinsho/bufferline.nvim` | plugin | Go to next buffer. |
| `:BufferLineCyclePrev` | `akinsho/bufferline.nvim` | plugin | Go to previous buffer. |
| `:BufferLineMoveNext` | `akinsho/bufferline.nvim` | plugin | Move current buffer right. |
| `:BufferLineMovePrev` | `akinsho/bufferline.nvim` | plugin | Move current buffer left. |
| `:BufferLineTogglePin` | `akinsho/bufferline.nvim` | plugin | Pin/unpin current buffer. |
| `:Git` | `tpope/vim-fugitive` | plugin | Open Fugitive git status interface. |
| `:Mason` | `mason-org/mason.nvim` | plugin | Open Mason UI for tools and servers. |

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
| `:InspectTree` | native | Show the Treesitter syntax tree for the buffer. |

## Notes

- This list focuses on commands explicitly wired by this configuration and key plugins in use.
- Some plugins expose many additional subcommands; those are documented in each plugin's `:help` pages.
