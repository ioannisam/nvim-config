function _G.MyQFTF()
    local out = {}
    local items = vim.fn.getqflist()
    for _, item in ipairs(items) do
        out[#out + 1] = item.text
    end
    return out
end

vim.go.quickfixtextfunc = "v:lua.MyQFTF"

return {
    "rcarriga/nvim-notify",
    lazy = false,
    config = function()
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
                    vim.fn.setqflist({}, "r", { title = "Notifications", items = { header_item } })
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

                vim.fn.setqflist({}, "r", {
                    title = "Notifications",
                    items = items,
                    idx = math.max(1, math.min(idx, #items)),
                })
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
                    vim.fn.setqflist({}, "r", { title = "Notifications", items = { header_item } })
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
                    vim.fn.setqflist({}, "r", { title = "Notifications", items = { header } })
                else
                    local header_item = {
                        bufnr = 0,
                        lnum = 0,
                        col = 0,
                        text = header_text(),
                        type = " ",
                        user_data = { header = true },
                    }
                    vim.fn.setqflist({}, "r", { title = "Notifications", items = { header_item } })
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

                vim.fn.setqflist({}, "r", {
                    title = "Notifications",
                    items = items,
                    idx = safe_idx,
                })

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

        vim.keymap.set("n", "<Esc>", function()
            if vim.v.hlsearch == 1 then vim.cmd("nohlsearch") end
            notify.dismiss({ silent = true, pending = true })
        end, { desc = "Esc: clear highlights and dismiss notifications" })

        vim.keymap.set("n", "<leader>xn", function()
            NQF.reset_session()

            local notify = require("notify")
            local history = notify.history()

            local items = {}
            local type_map = { DEBUG = "N", INFO = "I", WARN = "W", ERROR = "E", TRACE = "N" }
            local icon_map = { DEBUG = "", ERROR = "", INFO = "", TRACE = "✎", WARN = "" }

            for _, notif in ipairs(history) do
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
                    local buf = vim.api.nvim_create_buf(false, true)
                    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

                    for i, line in ipairs(lines) do
                        local hl_group
                        if lvl == "ERROR" then
                            hl_group = "QFError"
                        elseif lvl == "WARN" then
                            hl_group = "QFWarn"
                        elseif lvl == "INFO" then
                            hl_group = "QFInfo"
                        elseif lvl == "DEBUG" then
                            hl_group = "QFDebug"
                        elseif lvl == "TRACE" then
                            hl_group = "QFTrace"
                        end
                        if hl_group then
                            vim.api.nvim_buf_add_highlight(buf, -1, hl_group, i - 1, 0, -1)
                        end

                        local icons = {
                            [""] = "QFIconError",
                            [""] = "QFIconWarn",
                            [""] = "QFIconInfo",
                            [""] = "QFIconDebug",
                            ["✎"] = "QFIconTrace",
                        }
                        local icon_match = line:match("^([%z\1-\127\194-\244][\128-\191]*)")
                        if icon_match and icons[icon_match] then
                            vim.api.nvim_buf_add_highlight(buf, -1, icons[icon_match], i - 1, 0, #icon_match)
                        end
                    end

                    table.insert(items, {
                        bufnr = buf,
                        lnum = 1,
                        col = 1,
                        text = string.format("%s | %s %-5s ▶ %s", time, icon, lvl, summary),
                        type = qftype,
                        user_data = { key = key, bufnr = buf, lvl = lvl, time = notif.time },
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

            vim.fn.setqflist({}, "r", { title = "Notifications", items = items })

            local qf_open = false
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "quickfix" then
                    qf_open = true
                    break
                end
            end

            if not qf_open then
                vim.cmd("copen")
                vim.schedule(function()
                    vim.cmd("call SetQFSyntax()")
                end)
            else
                vim.cmd("cclose")
            end
        end, { desc = "Toggle Notifications History in quickfix (for bqf)" })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "qf",
            callback = function(args)
                local title = vim.fn.getqflist({ title = 1 }).title
                if title ~= "Notifications" then return end
                local opts = { buffer = args.buf, nowait = true, desc = "Notifications QF" }

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

                vim.keymap.set("n", "<Esc>", function()
                    if vim.v.hlsearch == 1 then vim.cmd("nohlsearch") end
                    notify.dismiss({ silent = true, pending = true })
                    vim.cmd("cclose")
                end, opts)

                vim.keymap.set("n", "?", function()
                    local help = {
                        "Notifications Quickfix Help:",
                        " d / <Del>  → delete notification under cursor",
                        " D          → delete all notifications (keep window for undo)",
                        " u          → undo last delete",
                        " U          → undo all deletes",
                        " <Esc>      → clear highlights + dismiss transient notifications + close",
                        " q          → close the Notifications window",
                        " <leader>xn → toggle Notifications history window",
                        " ?          → show this help",
                    }

                    vim.notify(table.concat(help, "\n"), vim.log.levels.INFO, {
                        title = "Notify 󰂟",
                        timeout = 10000,
                    })
                end, { buffer = true, desc = "Show Notifications QF help" })
            end,
        })
    end,
}
