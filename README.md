# Neovim Configuration

A modular Neovim configuration managed with [lazy.nvim](https://github.com/folke/lazy.nvim).
Plugin specs live in `lua/plugins/<category>/`, one file per plugin.

## Feature Tiers

This configuration ships as five branches. They differ only in how many plugins are
enabled — the structure, keymaps, and conventions are the same throughout, so what you
learn on one tier carries over to the next.

| Branch | For | Roughly |
| --- | --- | --- |
| `tiny` | A minimal, fast, dependency-light editor. Learning what the config does. | Core editing only |
| `minimal` | Light code editing and quick fixes over SSH or on small machines. | Adds navigation and git basics |
| `standard` | Everyday development. The sensible default. | Adds LSP, completion and diagnostics |
| `verbose` | Full-featured development, including AI assistance. | Adds debugging, AI and extra UI |
| `main` / `extravagant` | Everything, including games and novelties. | The complete set |

`main` is the superset - every branch is derived from it by removing plugins.

### Choosing a tier

Clone once, then check out the branch you want:

```bash
git clone <your-repo-url> ~/.config/nvim
cd ~/.config/nvim
git checkout standard
nvim
```

On first launch `lazy.nvim` bootstraps itself and installs the plugins for that branch.

### Switching tiers later

```bash
cd ~/.config/nvim
git checkout verbose
nvim +"Lazy sync" +qa
```

`Lazy sync` installs anything the new branch adds and removes anything it drops, so the
plugin directory matches the branch. Restart Neovim afterwards.

To see what a branch contains before switching:

```bash
git diff --stat main..tiny -- lua/plugins
```

### Staying up to date

Fixes and new plugins land on `main` first and are merged outward:

```bash
git checkout standard
git merge main
nvim +"Lazy sync" +qa
```

## Documentation

| Document | Contents |
| --- | --- |
| [doc/setup.md](doc/setup.md) | Prerequisites, installation, first-run steps, validation |
| [doc/plugins.md](doc/plugins.md) | Every plugin, its category, and what it does |
| [doc/keymaps.md](doc/keymaps.md) | All keymaps, grouped by plugin and by mode |
| [doc/commands.md](doc/commands.md) | Custom and plugin commands available in this config |

Documentation on every branch describes that branch. `doc/plugins.md` on `tiny` lists only
the plugins `tiny` actually ships.

## Layout

```
init.lua                 entry point
lua/config/              options, keymaps, lazy.nvim bootstrap
lua/plugins/<category>/  one file per plugin
lua/utils/               shared helpers
doc/                     documentation
```

Categories: `ai`, `console`, `docs`, `editor`, `fun`, `git`, `keymaps`, `lsp`,
`navigation`, `ui`.

The leader key is `<Space>`. Press it and wait to see the available keymaps via
[which-key](https://github.com/folke/which-key.nvim).
