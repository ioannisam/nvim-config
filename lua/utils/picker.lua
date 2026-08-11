local M = {}

function M.union(selected, current, opts)
    opts = opts or {}
    local identity = opts.identity or function(item)
        return item
    end
    local allow = opts.allow or function()
        return true
    end
    local include_current = opts.include_current ~= false

    local function key_of(item)
        local id = identity(item)
        if id == nil then
            return item
        end
        return id
    end

    local out, seen = {}, {}
    local has_selection = selected ~= nil and #selected > 0

    for _, item in ipairs(selected or {}) do
        local id = key_of(item)
        if not seen[id] and allow(item) then
            seen[id] = true
            table.insert(out, item)
        end
    end

    if current ~= nil and (include_current or not has_selection) then
        if allow(current) and not seen[key_of(current)] then
            table.insert(out, current)
        end
    end

    return out
end

function M.resolve_selection(prompt_bufnr, opts)
    local action_state = require("telescope.actions.state")
    local picker = action_state.get_current_picker(prompt_bufnr)
    local selected = picker and picker:get_multi_selection() or {}
    local current = action_state.get_selected_entry()

    return M.union(selected, current, opts)
end

function M.multiselect(items, opts, on_confirm)
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local themes = require("telescope.themes")

    opts = opts or {}
    local prompt = opts.prompt or "Select items:"
    local format_item = opts.format_item

    if #items == 0 then
        if on_confirm then
            on_confirm({})
        end
        return
    end

    local entries = {}
    for idx, item in ipairs(items) do
        local display_text = format_item and format_item(item) or tostring(item)
        table.insert(entries, {
            value = item,
            display = display_text,
            ordinal = tostring(idx) .. " " .. display_text,
        })
    end

    local finder = finders.new_table({
        results = entries,
        entry_maker = function(entry)
            return entry
        end,
    })

    local theme_opts = themes.get_dropdown({
        previewer = false,
        prompt_position = "top",
        layout_config = { height = math.min(#entries + 4, 15) },
    })

    local picker = pickers.new(theme_opts, {
        prompt_title = prompt,
        finder = finder,
        sorter = conf.generic_sorter({}),
        previewer = false,
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local chosen = M.resolve_selection(prompt_bufnr)

                local results = {}
                for _, entry in ipairs(chosen) do
                    table.insert(results, entry.value)
                end

                actions.close(prompt_bufnr)
                if on_confirm then
                    on_confirm(results)
                end
            end)

            map("i", "<Tab>", actions.toggle_selection + actions.move_selection_next)
            map("n", "<Tab>", actions.toggle_selection + actions.move_selection_next)
            map("i", "<S-Tab>", actions.toggle_selection + actions.move_selection_previous)
            map("n", "<S-Tab>", actions.toggle_selection + actions.move_selection_previous)

            return true
        end,
    })

    picker:find()
end

return M
