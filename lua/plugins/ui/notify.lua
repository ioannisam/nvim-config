function _G.MyQFTF(info)
    local list = vim.fn.getqflist({ id = info.id, items = 1 })
    local out = {}
    for i = info.start_idx, info.end_idx do
        local item = list.items[i]
        out[#out + 1] = item and item.text or ""
    end
    return out
end

return {
    "rcarriga/nvim-notify",
    lazy = false,
    config = function()
        local details_win = nil
        local details_buf = nil
        local notify = require("notify")
        notify.setup({
            timeout = 1500,
            stages = "fade_in_slide_out",
            fps = 60,
            icons = {
                DEBUG = "",
                ERROR = "",
                INFO = "",
                TRACE = "✎",
                WARN = "",
            },
            level = 2,
            time_formats = {
                notification = "%H:%M",
                notification_history = "%Y-%m-%dT%H:%M",
            },
            background_colour = "#000000",
            top_down = true,
            render = "default",
        })

        vim.notify = notify

        local QF_TITLE = "Notifications"
        local function set_qflist(items, idx, action)
            vim.fn.setqflist({}, action or "r", {
                title = QF_TITLE,
                items = items,
                idx = idx,
                quickfixtextfunc = "v:lua.MyQFTF",
            })
        end

        local NQF = (function()
            local dismissed = {}
            local removed_stack = {}

            local function key_for(lvl, time, summary)
                return table.concat({ tostring(time or 0), lvl or "INFO", summary or "" }, "\31")
            end

            local function header_text()
                return string.format("Notifications History (press '?' for help) (⎌ %d)", #removed_stack)
            end

            local function get_items_and_cursor_idx()
                local items = vim.fn.getqflist()
                if not items then return {}, 0 end
                local count = #items

                local idx = nil
                if vim.bo.buftype == "quickfix" then
                    local ok, cur = pcall(vim.api.nvim_win_get_cursor, 0)
                    if ok and type(cur) == "table" then
                        local line = cur[1]
                        if line >= 1 and line <= count then
                            idx = line
                        end
                    end
                end

                if (not idx or idx == 0) then
                    local info = vim.fn.getqflist({ idx = 0 })
                    if info and info.idx and info.idx >= 1 and info.idx <= count then
                        idx = info.idx
                    end
                end

                return items, idx
            end

            local function delete()
                local items, idx = get_items_and_cursor_idx()
                if not items then items = {} end

                if #items == 0 then
                    local header_item = {
                        bufnr = 0,
                        lnum = 0,
                        col = 0,
                        text = header_text(),
                        type = " ",
                        user_data = { header = true },
                    }
                    set_qflist({ header_item })
                    return
                end

                if not idx or idx == 0 or not items[idx] then
                    return
                end

                if items[idx].user_data and items[idx].user_data.header then
                    return
                end

                local it = items[idx]
                table.insert(removed_stack, { item = it, idx = idx })

                local ud = it.user_data or {}
                if ud.key then dismissed[ud.key] = true end

                table.remove(items, idx)

                if items[1] and items[1].user_data and items[1].user_data.header then
                    items[1].text = header_text()
                end

                set_qflist(items, math.max(1, math.min(idx, #items)))
            end

            local function delete_all()
                local info = vim.fn.getqflist({ items = 0 })
                local items = info.items or {}

                if not items or #items == 0 then
                    local header_item = {
                        bufnr = 0,
                        lnum = 0,
                        col = 0,
                        text = header_text(),
                        type = " ",
                        user_data = { header = true },
                    }
                    set_qflist({ header_item })
                    return
                end

                local header = (items[1] and items[1].user_data and items[1].user_data.header) and items[1] or nil

                for i = #items, 1, -1 do
                    if not (items[i].user_data and items[i].user_data.header) then
                        table.insert(removed_stack, { item = items[i], idx = i })
                        local ud = items[i].user_data or {}
                        if ud.key then dismissed[ud.key] = true end
                    end
                end

                if header then
                    header.text = header_text()
                    set_qflist({ header })
                else
                    local header_item = {
                        bufnr = 0,
                        lnum = 0,
                        col = 0,
                        text = header_text(),
                        type = " ",
                        user_data = { header = true },
                    }
                    set_qflist({ header_item })
                end
            end

            local function undo_delete()
                local entry = table.remove(removed_stack)
                if not entry then return end

                local info  = vim.fn.getqflist({ idx = 0, items = 0, title = 0 })
                local items = info.items or {}
                local header_present = items[1] and items[1].user_data and items[1].user_data.header
                local min_idx = header_present and 2 or 1

                local safe_idx = math.max(min_idx, math.min(entry.idx or (#items + 1), #items + 1))

                table.insert(items, safe_idx, entry.item)
                if entry.item.user_data and entry.item.user_data.key then
                    dismissed[entry.item.user_data.key] = nil
                end

                if items[1] and items[1].user_data and items[1].user_data.header then
                    items[1].text = header_text()
                end

                set_qflist(items, safe_idx)

                local qf_open = false
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "quickfix" then
                        qf_open = true
                        break
                    end
                end
                if not qf_open then vim.cmd("copen") end
            end

            local function undo_all()
                while #removed_stack > 0 do
                    undo_delete()
                end
            end

            local function reset_session()
                removed_stack = {}
            end

            local function undo_count()
                return #removed_stack
            end

            return {
                key_for = key_for,
                dismissed = dismissed,
                delete = delete,
                delete_all = delete_all,
                undo_delete = undo_delete,
                undo_all = undo_all,
                reset_session = reset_session,
                undo_count = undo_count,
            }
        end)()

        _G.NQF = NQF

        vim.keymap.set("n", "<Esc>", function()
            if vim.v.hlsearch == 1 then vim.cmd("nohlsearch") end
            notify.dismiss({ silent = true, pending = true })
        end, { desc = "Esc: clear highlights and dismiss notifications" })

        vim.keymap.set("n", "<leader>xn", function()
            local special_windows = require("utils.special_windows")
            local notify = require("notify")

            local NQF = _G.NQF or nil
            if not NQF then
                vim.notify("NQF not found", vim.log.levels.ERROR, { title = "Notify 󰂟" })
                return
            end

            local qf_open = false
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "quickfix" then
                    qf_open = true
                    break
                end
            end

            if qf_open then
                local showing_notifications = vim.fn.getqflist({ title = 1 }).title == QF_TITLE
                vim.cmd("cclose")
                if details_win and vim.api.nvim_win_is_valid(details_win) then
                    vim.api.nvim_win_close(details_win, true)
                end
                details_win, details_buf = nil, nil
                if showing_notifications then
                    return
                end
            end

            local history = notify.history()

            NQF.reset_session()

            local items = {}
            local type_map = { DEBUG = "N", INFO = "I", WARN = "W", ERROR = "E", TRACE = "N" }
            local icon_map = { DEBUG = "", ERROR = "", INFO = "", TRACE = "✎", WARN = "" }

            for i = #history, 1, -1 do
                local notif = history[i]
                local raw = notif.level
                local lvl
                if type(raw) == "number" then
                    lvl = ({
                        [vim.log.levels.TRACE] = "TRACE",
                        [vim.log.levels.DEBUG] = "DEBUG",
                        [vim.log.levels.INFO]  = "INFO",
                        [vim.log.levels.WARN]  = "WARN",
                        [vim.log.levels.ERROR] = "ERROR",
                    })[raw]
                elseif type(raw) == "string" then
                    lvl = raw:upper()
                end
                lvl = lvl or "INFO"

                local qftype = type_map[lvl]
                local icon = icon_map[lvl] or ""
                local time = os.date("%H:%M", notif.time)
                local msg = notif.message

                if type(msg) == "table" then
                    msg = table.concat(
                        vim.tbl_map(function(m)
                            return (type(m) == "string" and m) or vim.inspect(m)
                        end, msg),
                        "\n"
                    )
                end

                local max_len = 150
                local lines = {}
                for line in msg:gmatch("[^\n]+") do
                    while #line > max_len do
                        local pos = line:sub(1, max_len):find("%s[^%s]*$") or max_len
                        table.insert(lines, line:sub(1, pos))
                        line = line:sub(pos + 1)
                    end
                    table.insert(lines, line)
                end

                local summary = lines[1] or ""
                local key = NQF.key_for(lvl, notif.time, summary)
                if not NQF.dismissed[key] then
                    table.insert(items, {
                        bufnr = 0,
                        lnum = 1,
                        col = 1,
                        text = string.format("%s | %s %-5s ▶ %s", time, icon, lvl, summary),
                        type = qftype,
                        user_data = { key = key, lvl = lvl, time = notif.time, lines = lines },
                    })
                end
            end

            local undo_count = NQF.undo_count()
            local header_item = {
                bufnr = 0,
                lnum = 0,
                col = 0,
                text = string.format("Notifications History (press '?' for help) (⎌ %d)", undo_count),
                type = " ",
                user_data = { header = true },
            }
            table.insert(items, 1, header_item)

            local action = vim.fn.getqflist({ title = 1 }).title == QF_TITLE and "r" or " "
            set_qflist(items, nil, action)

            special_windows.prepare_for_open("notifications")
            vim.cmd("copen")
            local qf_info = vim.fn.getqflist({ winid = 0 })
            local qf_win = qf_info and qf_info.winid or 0
            if qf_win and qf_win ~= 0 and vim.api.nvim_win_is_valid(qf_win) then
                local qf_buf = vim.api.nvim_win_get_buf(qf_win)
                vim.bo[qf_buf].buflisted = false
                vim.b[qf_buf].bufferline_exclude = true
            end
            vim.schedule(function()
                vim.cmd("call SetQFSyntax()")
            end)
        end, { desc = "Toggle Notifications History in quickfix (for bqf)" })

        local function open_float(title, lines, opts)
            opts = opts or {}
            local width = opts.width or math.floor(vim.o.columns * 0.6)
            local height = opts.height or math.min(#lines + 4, math.floor(vim.o.lines * 0.5))
            local row = math.floor((vim.o.lines - height) / 2)
            local col = math.floor((vim.o.columns - width) / 2)

            local buf = vim.api.nvim_create_buf(false, true)
            vim.bo[buf].buftype = "nofile"
            vim.bo[buf].bufhidden = "wipe"
            vim.bo[buf].swapfile = false
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

            vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
            vim.api.nvim_set_option_value("readonly", true, { buf = buf })
            vim.api.nvim_set_option_value("filetype", "notifydetails", { buf = buf })

            local block_keys = { "d", "dd", "x", "p", "i", "a", "o", "O", "c", "r", "s" }
            for _, key in ipairs(block_keys) do
                vim.keymap.set("n", key, "<nop>", { buffer = buf, nowait = true })
            end

            local win = vim.api.nvim_open_win(buf, true, {
                relative = "editor",
                width = width,
                height = height,
                row = row,
                col = col,
                style = "minimal",
                border = "rounded",
                title = title,
                title_pos = "center",
            })

            local function refocus_target()
                vim.schedule(function()
                    if opts.refocus_win and vim.api.nvim_win_is_valid(opts.refocus_win) then
                        vim.api.nvim_set_current_win(opts.refocus_win)
                        return
                    end

                    if opts.refocus_buf and vim.api.nvim_buf_is_valid(opts.refocus_buf) then
                        for _, w in ipairs(vim.api.nvim_list_wins()) do
                            if vim.api.nvim_win_get_buf(w) == opts.refocus_buf then
                                vim.api.nvim_set_current_win(w)
                                return
                            end
                        end
                    end
                end)
            end

            local function close_win()
                if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_close(win, true)
                end
            end

            vim.api.nvim_set_option_value("winhighlight", "Normal:Normal,FloatBorder:FloatBorder", { win = win })

            vim.keymap.set("n", "q", function()
                close_win()
            end, { buffer = buf, nowait = true, desc = "Close floating window" })

            vim.keymap.set("n", "<Esc>", function()
                close_win()
            end, { buffer = buf, nowait = true, desc = "Close floating window" })

            -- Ensure the float is focused (some quickfix/bqf flows can steal focus right after opening)
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_set_current_win(win)
                vim.schedule(function()
                    if vim.api.nvim_win_is_valid(win) then
                        vim.api.nvim_set_current_win(win)
                    end
                end)
                vim.defer_fn(function()
                    if vim.api.nvim_win_is_valid(win) then
                        vim.api.nvim_set_current_win(win)
                    end
                end, 10)
            end

            -- Close on focus loss, but with a tiny delay to ignore transient focus blips on open.
            vim.api.nvim_create_autocmd("WinLeave", {
                buffer = buf,
                once = true,
                callback = function()
                    vim.defer_fn(function()
                        if vim.api.nvim_win_is_valid(win) and vim.api.nvim_get_current_win() ~= win then
                            close_win()
                            refocus_target()
                        end
                    end, 20)
                end,
            })

            if opts.refocus_win or opts.refocus_buf then
                vim.api.nvim_create_autocmd("WinClosed", {
                    pattern = tostring(win),
                    once = true,
                    callback = function()
                        refocus_target()
                    end,
                })
            end

            return buf, win
        end

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "qf",
            callback = function(args)
                local title = vim.fn.getqflist({ title = 1 }).title
                if title ~= "Notifications" then return end
                local opts = { buffer = args.buf, nowait = true, desc = "Notifications QF" }

                vim.keymap.set("n", "<CR>", function()
                    local qf_win = vim.api.nvim_get_current_win()
                    local items = vim.fn.getqflist()
                    local line = vim.fn.line(".")
                    local item = items[line]
                    if not item or not item.user_data or not item.user_data.lines then return end

                    local lines = vim.deepcopy(item.user_data.lines)
                    table.insert(lines, "")
                    table.insert(lines, "───────────────────────────────────────────────")
                    table.insert(lines, "Press 'q' to close this window")

                    details_buf, details_win = open_float(
                        string.format(" Notification Details 󰂟 "),
                        lines,
                        { refocus_win = qf_win, refocus_buf = args.buf }
                    )
                end, vim.tbl_extend("force", opts, { desc = "Open notification detail in floating view" }))

                for _, key in ipairs({ "d", "<Delete>" }) do
                    vim.keymap.set("n", key, NQF.delete,
                        vim.tbl_extend("force", opts, { desc = "Delete notification under cursor" }))
                end
                vim.keymap.set("n", "D", NQF.delete_all,
                    vim.tbl_extend("force", opts, { desc = "Delete all notifications (keep qf open for undo)" }))

                vim.keymap.set("n", "u", NQF.undo_delete,
                    vim.tbl_extend("force", opts, { desc = "Undo last delete" }))
                vim.keymap.set("n", "U", NQF.undo_all,
                    vim.tbl_extend("force", opts, { desc = "Undo all deletes" }))

                vim.keymap.set("n", "q", function()
                    vim.cmd("cclose")
                end, opts)

                vim.keymap.set("n", "?", function()
                    local lines = {
                        " Notifications Quickfix Help ",
                        "───────────────────────────────",
                        " <leader>xn → toggle Notifications history window",
                        " <Esc>      → dismiss transient notifications",
                        " q          → close the Notifications window",
                        " d / <Del>  → delete notification under cursor",
                        " D          → delete all notifications (keep window for undo)",
                        " u          → undo last delete",
                        " U          → undo all deletes",
                        " ?          → show this help",
                        "",
                        " Press 'q' to close this help ",
                    }

                    open_float(" Notifications Help 󰂟 ", lines, {
                        width = math.floor(vim.o.columns * 0.5),
                        refocus_win_type = "quickfix",
                    })
                end, { buffer = args.buf, desc = "Show Notifications QF help" })
            end,
        })
    end,
}
