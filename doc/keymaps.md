# Keymaps

This document lists the keymaps of this configuration across different plugins and buffers.

## Which-key

| Mode | Keymap | Category | Description |
| --- | --- | --- | --- |
| n | `<leader>a` | General | Select all text in current buffer. |
| n | `<leader>w` | General | Switch window. |
| n | `<leader>n` | Neotree | Toggle Neo-tree. |
| n | `<leader>u` | General | Toggle UndoTree. |
| n | `<leader>o` | General | Toggle symbol outline (Aerial). |
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
| n | `<leader>mp` | Menu/Markdown | Toggle Markview preview. |
| n | `<leader>gt` | Git | Toggle diff UI. |
| n | `<leader>gn` | Git | Next hunk. |
| n | `<leader>gp` | Git | Previous hunk. |
| n | `<leader>gd` | Git | Preview hunk inline. |
| n | `<leader>gD` | Git | Preview hunk window. |
| n | `<leader>gb` | Git | Blame line. |
| n | `<leader>gr` | Git | Reset hunk. |
| n | `<leader>xD` | Diagnostics/Lists | Diagnostics (Trouble, all). |
| n | `<leader>xd` | Diagnostics/Lists | Diagnostics (Trouble, buffer). |
| n | `<leader>xs` | Diagnostics/Lists | Symbols (Trouble). |
| n | `<leader>xn` | Diagnostics/Lists | Toggle notifications history quickfix. |
| n | `<leader>xm` | Diagnostics/Lists | Buffer marks to quickfix. |
| n | `<leader>xM` | Diagnostics/Lists | Global marks to quickfix. |
| n | `<leader>le` | LSP/Lazy | Open diagnostics float. |
| n | `<leader>lr` | LSP/Lazy | Rename symbol. |
| n | `<leader>la` | LSP/Lazy | Code actions. |
| n | `<leader>lf` | LSP/Lazy | Format buffer. |
| n | `<leader>lt` | LSP/Lazy | Open Lazy UI. |
| n | `<leader>lu` | LSP/Lazy | Update plugins with Lazy. |
| n | `<leader>ff` | Telescope | Find files. |
| n | `<leader>fg` | Telescope | Live grep. |
| n | `<leader>fh` | Telescope | Help tags. |
| n | `<leader>fw` | Telescope | Grep word under cursor. |
| n | `<leader>fp` | Telescope | Project picker (project.nvim). |
| n | `<leader>sg` | Search | Global search (Spectre). |
| n | `<leader>sl` | Search | Local search (Spectre, file scope). |
| n | `<leader>swg` | Search Word / Selection | Search current word globally. |
| v | `<leader>swg` | Search Word / Selection | Search current selection globally. |
| n | `<leader>swl` | Search Word / Selection | Search current word locally. |
| v | `<leader>swl` | Search Word / Selection | Search current selection locally. |
| n | `<leader>vm` | Multi-cursor | Activate multi-cursor mode. |
| x | `<leader>vm` | Multi-cursor | Activate multi-cursor at visual start. |
| n | `<leader>cq` | Code/Chat | Todo quickfix list. |
| n | `<leader>yh` | Yank | Yank history picker (Telescope). |
| n | `<leader>yc` | Yank | Clear yank history. |

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
| n | Git | `a` | Git add selected/current. |
| n | Git | `u` | Git unstage selected/current. |
| n | Git | `r` | Git restore selected/current. |
| n | Git | `c` | Git commit. |
| n | Git | `p` | Git push. |
| n | Git | `g` | Git commit and push. |
| n | Git | `A` | Git add all. |
| n | Git | `U` | Git reset all staged. |
| n | Git | `R` | Git restore all files. |

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

## Spectre

| Mode | Keymap | Description |
| --- | --- | --- |
| n | `q` | Close Spectre panel. |
| n | `<leader>o` | Show options menu. |
| n | `<CR>` | Open file for selected entry. |
| n | `<Tab>` | Next query field. |
| n | `<S-Tab>` | Previous query field. |
| n | `<leader>r` | Replace current line. |
| n | `<leader>R` | Replace all. |
| n | `dl` | Delete line from results. |
| n | `tl` | Toggle result line enabled/disabled. |
| n | `ti` | Toggle ignore case. |
| n | `tu` | Toggle live update. |
| n | `th` | Toggle search hidden files. |
| n | `tq` | Send all items to quickfix. |
| n | `<leader>c` | Input replace command. |
| n | `<leader>l` | Resume last search. |
| n | `<leader>v` | Change result view mode. |
| n | `<leader>s` | Use sed replace engine. |
| n | `<leader>x` | Use oxi replace engine. |
| n | `<leader>t` | Select template. |

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

## Multi-cursor

| Mode | Keymap | Description |
| --- | --- | --- |
| n,x | `h` | Previous cursor. |
| n,x | `l` | Next cursor. |
| n,x | `j` | Add cursor on next line. |
| n,x | `k` | Add cursor on previous line. |
| n,x | `J` | Skip cursor to next line. |
| n,x | `K` | Skip cursor to previous line. |
| n,x | `n` | Add cursor to next match. |
| n,x | `p` | Add cursor to previous match. |
| n,x | `s` | Skip current match. |
| n,x | `c` | Delete cursor. |
| n,x | `t` | Toggle/enable cursors. |
| n | `<Esc>` | Exit/clear multi-cursor. |

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

## Aerial

Buffer-local inside the Aerial outline window.

| Mode | Keymap | Description |
| --- | --- | --- |
| n | `<CR>` | Jump to the symbol under the cursor. |
| n | `<2-LeftMouse>` | Jump to the symbol under the mouse. |
| n | `p` | Scroll the source window to the symbol without leaving Aerial. |
| n | `}` | Next symbol. |
| n | `{` | Previous symbol. |
| n | `X` | Expand all tree nodes. |
| n | `C` | Collapse all tree nodes. |
| n | `?` | Show help. |
| n | `q` | Close the Aerial window. |

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

## Yanky

`y`, `p`, and `P` are remapped so every yank and put flows through the yank ring.

| Mode | Keymap | Description |
| --- | --- | --- |
| n, x | `y` | Yank into the ring (with highlight). |
| n, x | `p` | Put after the cursor. |
| n, x | `P` | Put before the cursor. |
| n, x | `gp` | Put after, leaving the cursor at the end of the pasted text. |
| n, x | `gP` | Put before, leaving the cursor at the end of the pasted text. |
| n | `<C-n>` | Cycle to the next entry in the ring (immediately after a put). |
| n | `<C-p>` | Cycle to the previous entry in the ring (immediately after a put). |

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
| n | `[d` | nvim-lspconfig | Diagnostics previous. |
| n | `]d` | nvim-lspconfig | Diagnostics next. |
| n | `gd` | nvim-lspconfig | LSP go to definition (buffer-local). |
| n | `qi` | nvim-lspconfig | LSP hover docs (buffer-local). |
| n | `gr` | nvim-lspconfig | LSP references (buffer-local). |
| n | `gcd` | Comment.nvim | Trim comment marker on current line. |
| x | `gcd` | Comment.nvim | Trim comment markers in selection. |
| n | `tt` | treesj | TreeSJ toggle split/join. |
| n | `tj` | treesj | TreeSJ join. |
| n | `ts` | treesj | TreeSJ split. |
| n | `zR` | nvim-ufo | Open all folds (ufo). |
| n | `zM` | nvim-ufo | Close all folds (ufo). |
| n | `+` | dial.nvim | Dial increment. |
| n | `-` | dial.nvim | Dial decrement. |
| v | `+` | dial.nvim | Dial increment (visual, keep selection). |
| v | `-` | dial.nvim | Dial decrement (visual, keep selection). |
| n | `[i` | mini.indentscope | Jump to top of indent scope (mini.indentscope). |
| n | `]i` | mini.indentscope | Jump to bottom of indent scope (mini.indentscope). |
| n | `<Esc>` | lazy.nvim | Close Lazy window (lazy filetype). |
| n | `<Esc>` | todo-comments.nvim | Close quickfix/location list (todo quickfix filetype). |
| n | `<Esc>` | gitsigns.nvim | Close gitsigns preview float. |
| n | `gcc` | Comment.nvim | Toggle line comment (Comment.nvim). |
| n | `gbc` | Comment.nvim | Toggle block comment (Comment.nvim). |
| n,o,x | `gc` | Comment.nvim | Comment operator linewise (Comment.nvim). |
| n,o,x | `gb` | Comment.nvim | Comment operator blockwise (Comment.nvim). |
| i,s,c | `<C-d>` | which-key.nvim | Scroll down in which-key popup. |
| i,s,c | `<C-u>` | which-key.nvim | Scroll up in which-key popup. |
| n | `<C-u>` | neoscroll.nvim | Smooth scroll up (neoscroll). |
| n | `<C-d>` | neoscroll.nvim | Smooth scroll down (neoscroll). |
| n | `<C-b>` | neoscroll.nvim | Smooth page up (neoscroll). |
| n | `<C-f>` | neoscroll.nvim | Smooth page down (neoscroll). |
| n | `<C-y>` | neoscroll.nvim | Smooth line up (neoscroll). |
| n | `<C-e>` | neoscroll.nvim | Smooth line down (neoscroll). |
| n | `zt` | neoscroll.nvim | Smooth scroll current line to top (neoscroll). |
| n | `zz` | neoscroll.nvim | Smooth scroll current line to center (neoscroll). |
| n | `zb` | neoscroll.nvim | Smooth scroll current line to bottom (neoscroll). |
| n | `[c` | nvim-treesitter-context | Jump upward to the enclosing context line. |
| i | `<M-s>` | lsp_signature.nvim | Toggle the signature help window. |
| i | `<M-j>` | lsp_signature.nvim | Cycle to the next signature overload. |

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
| n | `/` | Search forward. |
| n | `?` | Search backward. |
| n | `n` | Next search match. |
| n | `N` | Previous search match. |
| n | `*` | Search word under cursor forward. |
| n | `#` | Search word under cursor backward. |
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
