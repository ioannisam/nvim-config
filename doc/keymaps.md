# Keymaps

This document lists the keymaps of this configuration across different plugins and buffers.

## Which-key

| Mode | Keymap | Category | Description |
| --- | --- | --- | --- |
| n | `<leader>a` | General | Select all text in current buffer. |
| n | `<leader>w` | General | Switch window. |
| n | `<leader>n` | Neotree | Toggle Neo-tree. |
| n | `<leader>bd` | Buffers | Delete current buffer. |
| n | `<leader>bD` | Buffers | Delete buffers via picker. |
| n | `<leader>bn` | Buffers | Next buffer. |
| n | `<leader>bp` | Buffers | Previous buffer. |
| n | `<leader>bl` | Buffers | Move buffer right. |
| n | `<leader>bh` | Buffers | Move buffer left. |
| n | `<leader>bb` | Buffers | Toggle pin buffer. |
| n | `<leader>bf` | Buffers | Create new file (floating input). |
| n | `<leader>ha` | Harpoon | Add file to Harpoon. |
| n | `<leader>hc` | Harpoon | Clear Harpoon marks. |
| n | `<leader>hm` | Harpoon | Open Harpoon menu. |
| n | `<leader>hd` | Harpoon | Delete Harpoon marks (multi-select). |
| n | `<leader>tn` | Terminal | New horizontal terminal. |
| n | `<leader>th` | Terminal | Toggle horizontal terminals. |
| n | `<leader>tr` | Terminal | Rename terminal. |
| n | `<leader>td` | Terminal | Delete focused terminal. |
| n | `<leader>tD` | Terminal | Delete terminals via picker. |
| n | `<leader>tt` | Terminal | Open native terminal. |
| n | `<leader>xn` | Diagnostics/Lists | Toggle notifications history quickfix. |
| n | `<leader>xm` | Diagnostics/Lists | Buffer marks to quickfix. |
| n | `<leader>xM` | Diagnostics/Lists | Global marks to quickfix. |
| n | `<leader>lt` | Lazy | Open Lazy UI. |
| n | `<leader>lu` | Lazy | Update plugins with Lazy. |
| n | `<leader>ff` | Telescope | Find files. |
| n | `<leader>fg` | Telescope | Live grep. |
| n | `<leader>fh` | Telescope | Help tags. |
| n | `<leader>fw` | Telescope | Grep word under cursor. |
| n | `<leader>fp` | Telescope | Project picker (project.nvim). |

## Neotree

| Mode | Source | Keymap | Description |
| --- | --- | --- | --- |
| n | All | `<2-LeftMouse>` | Open node under mouse. |
| n | All | `<CR>` | Open multi-selected nodes or current node. |
| n | All | `<Tab>` | Toggle multiselect and move next. |
| n | All | `<S-Tab>` | Toggle multiselect and move previous. |
| n | All | `s` | Open in vertical split. |
| n | All | `S` | Open in horizontal split. |
| n | All | `q` | Close Neo-tree window. |
| n | All | `>` | Next source. |
| n | All | `<` | Previous source. |
| n | All | `C` | Close all nodes. |
| n | All | `X` | Expand all nodes. |
| n | All | `?` | Show help. |
| n | Filesystem | `<BS>` | Navigate up. |
| n | Filesystem | `.` | Set root. |
| n | Filesystem | `H` | Toggle hidden files. |
| n | Filesystem | `R` | Refresh source. |
| n | Filesystem | `P` | Toggle preview. |
| n | Filesystem | `F` | Focus preview. |
| n | Filesystem | `a` | Add node. |
| n | Filesystem | `m` | Move node. |
| n | Filesystem | `r` | Rename node. |
| n | Filesystem | `d` | Delete node. |
| n | Filesystem | `c` | Copy node. |
| n | Filesystem | `y` | Copy to clipboard. |
| n | Filesystem | `x` | Cut to clipboard. |
| n | Filesystem | `p` | Paste from clipboard. |
| n | Filesystem | `i` | Show file details. |
| n | Filesystem | `/` | Filter on submit. |
| n | Filesystem | `f` | Fuzzy finder. |
| n | Filesystem | `<Esc>` | Clear filter. |
| n | Filesystem | `on` | Order by name. |
| n | Filesystem | `oc` | Order by created time. |
| n | Filesystem | `om` | Order by modified time. |
| n | Filesystem | `os` | Order by size. |
| n | Filesystem | `ot` | Order by type. |
| n | Filesystem | `od` | Order by diagnostics. |
| n | Filesystem | `og` | Order by git status. |
| n | Buffers | `d` | Delete selected/current buffer. |

## Telescope

| Keymap | Description |
| --- | --- |
| `↓, <C-j>` | Move selection next. |
| `↑, <C-k>` | Move selection previous. |
| `<Esc>` | Close picker. |
| `<Tab>` | Toggle selection and move next. |
| `<S-Tab>` | Toggle selection and move previous. |
| `<CR>` | Open selected files (or current if none selected). |

## ToggleTerm

| Mode | Keymap | Description |
| --- | --- | --- |
| n | `<leader><Up>` | Increase terminal height (ToggleTerm terminal buffer). |
| n | `<leader><Down>` | Decrease terminal height (ToggleTerm terminal buffer). |
| t | `<Esc>` | Exit terminal mode. |

## Notifications

| Keymap | Description |
| --- | --- |
| `<Esc>` | Clear search highlight and dismiss notifications. |
| `q` | Close notification detail float. |
| `<Esc>` | Close notification detail float. |
| `<CR>` | Open selected notification detail (Notifications quickfix). |
| `d` | Delete notification under cursor (Notifications quickfix). |
| `<Delete>` | Delete notification under cursor (Notifications quickfix). |
| `D` | Delete all notifications (Notifications quickfix). |
| `u` | Undo last delete (Notifications quickfix). |
| `U` | Undo all deletes (Notifications quickfix). |
| `q` | Close Notifications quickfix. |
| `?` | Show Notifications quickfix help. |
| `d,x,p,i,a,o,O,c,r,s` | Disabled in notification detail float (`<nop>`). |

## Treesitter

| Mode | Keymap | Description |
| --- | --- | --- |
| n | `<C-Space>` | Start incremental selection at the node under the cursor. |
| x | `<C-Space>` | Expand selection to the parent node. |
| x | `<BS>` | Shrink selection to the previous node. |
| x, o | `af` | Select around function. |
| x, o | `if` | Select inside function. |
| x, o | `ac` | Select around class. |
| x, o | `ic` | Select inside class. |
| n, x, o | `]m` | Move to next function start. |
| n, x, o | `[m` | Move to previous function start. |
| n, x, o | `]]` | Move to next class start. |
| n, x, o | `[[` | Move to previous class start. |

## Marks

Global mappings provided by `marks.nvim` (`default_mappings = true`).

| Mode | Keymap | Description |
| --- | --- | --- |
| n | `mx` | Set mark `x` (any lowercase/uppercase letter). |
| n | `m,` | Set the next available lowercase mark. |
| n | `m;` | Toggle the next available mark on the current line. |
| n | `m:` | Preview a mark (prompts for the mark name). |
| n | `m]` | Move to the next mark. |
| n | `m[` | Move to the previous mark. |
| n | `dmx` | Delete mark `x`. |
| n | `dm-` | Delete all marks on the current line. |
| n | `dm<Space>` | Delete all marks in the current buffer. |
| n | `m0` .. `m9` | Add a bookmark to group 0-9. |
| n | `dm0` .. `dm9` | Delete all bookmarks in group 0-9. |
| n | `m}` | Move to the next bookmark of the same group. |
| n | `m{` | Move to the previous bookmark of the same group. |
| n | `dm=` | Delete the bookmark under the cursor. |

## Tmux

Provided by `vim-tmux-navigator`. The same keys move between Neovim splits and
tmux panes; when there is no split left in that direction, tmux takes over.
Requires the matching tpm plugin in `~/.config/tmux/tmux.conf`.

| Mode | Keymap | Description |
| --- | --- | --- |
| n | `<C-h>` | Go to the window/pane on the left. |
| n | `<C-j>` | Go to the window/pane below. |
| n | `<C-k>` | Go to the window/pane above. |
| n | `<C-l>` | Go to the window/pane on the right. |
| n | `<C-\>` | Go to the previously focused window/pane. |

## Misc

| Mode | Keymap | Plugin | Description |
| --- | --- | --- | --- |
| v | `*` | - | Search visual selection. |
| n | `J` | vim-move | Move line down. |
| n | `K` | vim-move | Move line up. |
| v | `J` | vim-move | Move selection down. |
| v | `K` | vim-move | Move selection up. |
| n | `<M-J>` | vim-move | Join lines (`J` is taken by vim-move). |
| x | `<M-J>` | vim-move | Join the selected lines. |
| n | `<leader>1..<leader>9` | bufferline.nvim | Jump to buffer by index. |
| n | `<A-1>..<A-9>` | bufferline.nvim | Jump to buffer by index (alternative). |
| n | `<2-LeftMouse>` | bufferline.nvim | Create new buffer when double-clicking the bufferline row (falls through to select-word elsewhere). |
| n | `<Esc>` | lazy.nvim | Close Lazy window (lazy filetype). |
| i,s,c | `<C-d>` | which-key.nvim | Scroll down in which-key popup. |
| i,s,c | `<C-u>` | which-key.nvim | Scroll up in which-key popup. |
| n | `[c` | nvim-treesitter-context | Jump upward to the enclosing context line. |

## Native

| Mode | Keymap | Description |
| --- | --- | --- |
| n | `u` | Undo last change. |
| n | `<C-r>` | Redo. |
| n | `p` | Paste after cursor. |
| n | `P` | Paste before cursor. |
| n | `x` | Delete character under cursor. |
| n | `dd` | Delete current line. |
| n | `D` | Delete to end of line. |
| n | `yy` | Yank current line. |
| n | `Y` | Yank from cursor to end of line. |
| n | `.` | Repeat last change. |
| n | `o` | Open new line below and enter insert mode. |
| n | `O` | Open new line above and enter insert mode. |
| n | `i` | Insert before cursor. |
| n | `I` | Insert at first non-blank in line. |
| n | `a` | Append after cursor. |
| n | `A` | Append at end of line. |
| n | `v` | Start visual mode (characterwise). |
| n | `V` | Start visual mode (linewise). |
| n | `<C-v>` | Start visual block mode. |
| n | `w` | Jump to next word start. |
| n | `b` | Jump to previous word start. |
| n | `e` | Jump to end of word. |
| n | `0` | Jump to start of line. |
| n | `^` | Jump to first non-blank in line. |
| n | `$` | Jump to end of line. |
| n | `gg` | Jump to first line. |
| n | `G` | Jump to last line. |
| n | `f{char}` | Find next character on line. |
| n | `t{char}` | Move before next character on line. |
| n | `;` | Repeat last `f`/`t`/`F`/`T`. |
| n | `n` | Next search match. |
| n | `N` | Previous search match. |
| n | `>>` | Indent line right. |
| n | `<<` | Indent line left. |
| n | `%` | Jump to matching pair (brackets/parens). |
| n | `:` | Enter command-line mode. |
| x | `y` | Yank selection. |
| x | `d` | Delete selection. |
| x | `c` | Change selection. |
| x | `>` | Indent selection right. |
| x | `<` | Indent selection left. |
| x | `p` | Replace selection with default register. |
| i | `<Esc>` | Return to normal mode. |
| i | `<C-w>` | Delete previous word. |
| i | `<C-u>` | Delete to start of insert line. |
| i | `<C-o>` | Execute one normal-mode command, then return to insert mode. |
