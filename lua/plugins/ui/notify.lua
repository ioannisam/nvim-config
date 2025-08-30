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
    {
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
                level = 2, -- 1 = DEBUG, 2 = INFO, 3 = WARN, 4 = ERROR
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
                local last_removed, last_idx

                local function key_for(lvl, time, summary)
                    return table.concat({ tostring(time or 0), lvl or "INFO", summary or "" }, "\31")
                end

                local function delete_under_cursor()
                    if vim.bo.buftype ~= "quickfix" then
                        return
                    end
                    local info = vim.fn.getqflist({ idx = 0, items = 0, title = 0 })
                    if not info or info.idx == 0 then
                        return
                    end

                    local items = info.items or vim.fn.getqflist()
                    local idx = info.idx
                    local it = items[idx]
                    if not it then
                        return
                    end

                    last_removed, last_idx = it, idx

                    local ud = it.user_data or {}
                    if ud.key then
                        dismissed[ud.key] = true
                    end

                    table.remove(items, idx)
                    vim.fn.setqflist({}, "r", {
                        title = "Notifications",
                        items = items,
                        idx = math.min(idx, #items),
                    })
                    if #items == 0 then
                        vim.cmd("cclose")
                    end
                end

                local function undo_delete()
                    if vim.bo.buftype ~= "quickfix" then
                        return
                    end
                    if not last_removed then
                        return
                    end

                    local info = vim.fn.getqflist({ idx = 0, items = 0, title = 0 })
                    local items = info.items or vim.fn.getqflist()
                    local idx = math.min(last_idx or (#items + 1), #items + 1)

                    table.insert(items, idx, last_removed)
                    if last_removed.user_data and last_removed.user_data.key then
                        dismissed[last_removed.user_data.key] = nil
                    end

                    vim.fn.setqflist({}, "r", {
                        title = "Notifications",
                        items = items,
                        idx = idx,
                    })

                    last_removed, last_idx = nil, nil
                end

                return {
                    key_for = key_for,
                    dismissed = dismissed,
                    delete_under_cursor = delete_under_cursor,
                    undo_delete = undo_delete,
                }
            end)()

            vim.keymap.set("n", "<Esc>", function()
                if vim.v.hlsearch == 1 then
                    vim.cmd("nohlsearch")
                end
                notify.dismiss({ silent = true, pending = true })
            end, { desc = "Esc: clear highlights and dismiss notifications" })

            vim.keymap.set("n", "<leader>xn", function()
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

                    -- wrap+split into lines
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
                        -- scratch buffer for preview
                        local buf = vim.api.nvim_create_buf(false, true)
                        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

                        -- optional per-line highlighting
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
                                hl_group = "QFArrowTrace"
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

            -- Buffer-local mappings only for our Notifications quickfix
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "qf",
                callback = function(args)
                    local title = vim.fn.getqflist({ title = 1 }).title
                    if title ~= "Notifications" then
                        return
                    end
                    local opts = { buffer = args.buf, nowait = true, desc = "Notifications QF" }
                    vim.keymap.set(
                        "n",
                        "dd",
                        NQF.delete_under_cursor,
                        vim.tbl_extend("force", opts, { desc = "Delete notification" })
                    )
                    vim.keymap.set("n", "u", NQF.undo_delete, vim.tbl_extend("force", opts, { desc = "Undo delete" }))
                end,
            })
        end,
    },
}
