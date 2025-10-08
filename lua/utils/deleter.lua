local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local themes = require("telescope.themes")

function M.multiselect(items, opts, on_confirm)
    opts = opts or {}
    local prompt = opts.prompt or "Select items:"
    local format_item = opts.format_item

    if #items == 0 then
        if on_confirm then on_confirm({}) end
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

    local finder = finders.new_table {
        results = entries,
        entry_maker = function(entry) return entry end,
    }

    local theme_opts = themes.get_dropdown {
        previewer = false,
        prompt_position = "top",
        results_height = math.min(#entries, 5),
    }

    local picker = pickers.new(theme_opts, {
        prompt_title = prompt,
        finder = finder,
        sorter = conf.generic_sorter({}),
        previewer = false,
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local picker = action_state.get_current_picker(prompt_bufnr)
                local selections = picker:get_multi_selection()
                local current = action_state.get_selected_entry()
                local results = {}
                local already_selected = {}

                for _, entry in ipairs(selections) do
                    table.insert(results, entry.value)
                    already_selected[entry.value] = true
                end

                if current and current.value and not already_selected[current.value] then
                    table.insert(results, current.value)
                end

                actions.close(prompt_bufnr)
                if on_confirm then on_confirm(results) end
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
