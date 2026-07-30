# Setup

This document explains how to install and run this Neovim configuration on a fresh machine.

## Prerequisites

Install these base tools first:

- Neovim 0.11+ (required: the LSP setup uses `vim.lsp.config`/`vim.lsp.enable`)
- Git
- `ripgrep` (`rg`)
- `fd` (or `fdfind` on some distros)
- `make` and a C compiler toolchain (needed for native plugin builds)
- `tree-sitter` CLI (required: `nvim-treesitter` compiles parsers with it)
- `curl` (optional, useful for external installers)

On Arch, the tree-sitter CLI is `extra/tree-sitter-cli`:

```bash
sudo pacman -S tree-sitter-cli
```

On Linux, also ensure you have a Nerd Font configured in your terminal for icon support.

## Install The Config

1. Back up your current Neovim config (if any):

```bash
mv ~/.config/nvim ~/.config/nvim.backup.$(date +%s)
```

2. Clone this repository into the Neovim config path:

```bash
git clone <your-repo-url> ~/.config/nvim
```

3. Start Neovim:

```bash
nvim
```

On first launch, `lazy.nvim` will bootstrap automatically and install plugins.

## First Run Steps

Inside Neovim, run:

- `:Lazy sync` to install/update plugins
- `:TSUpdate` to compile the Treesitter parsers
- `:Mason` and install any missing language servers/tools you want
- `:checkhealth` to detect missing providers and binaries

If Telescope FZF native fails to build, verify:

- `make` is installed
- compiler tools are installed (`gcc`/`clang`, libc headers)

Then rerun `:Lazy sync`.

If Treesitter reports missing parsers on startup, verify the `tree-sitter` CLI is on
your `PATH`, then rerun `:TSUpdate`. Check with `:checkhealth nvim-treesitter`.

## Optional Providers

For full feature support, install optional providers:

- Python provider (`pynvim`)
- Node provider (`neovim` npm package)

Example:

```bash
python3 -m pip install --user pynvim
npm install -g neovim
```

## Validate Setup

Quick validation checklist:

- `:Lazy` opens and shows plugins loaded
- `:Mason` opens normally
- `:InspectTree` renders a syntax tree in a source file
- `<leader>ff` opens Telescope find files
- `<leader>n` toggles Neo-tree
- `<leader>o` toggles the Aerial symbol outline
- `<leader>fp` lists known projects
- `<leader>cc` opens Copilot Chat (after Copilot auth)
- `<leader>ca` opens CodeCompanion chat (after `ANTHROPIC_API_KEY` is exported)
- `<leader>zt` opens Typr

## Updating

To update later:

- `:Lazy update`
- `:Mason` to update tooling as needed
- restart Neovim

If something breaks after updates, check `lazy-lock.json` changes and run `:checkhealth`.
