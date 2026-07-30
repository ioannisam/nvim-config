
local LOGO = {
    "██████   ██    ██  ██████ ",
    "██   ██  ██    ██  ██   ██",
    "██   ██  ██    ██  ██   ██",
    "██   ██   ██  ██   ██   ██",
    "██████     ████    ██████ ",
}

local COLORS = { "#ff5555", "#ffb86c", "#f1fa8c", "#50fa7b", "#8be9fd", "#bd93f9", "#ff79c6" }

local function logo_cells()
    local rows = {}
    for _, line in ipairs(LOGO) do
        table.insert(rows, vim.fn.split(line, "\\zs"))
    end
    return rows
end

local function define_highlights()
    for i, color in ipairs(COLORS) do
        vim.api.nvim_set_hl(0, "ScreensaverDvd" .. i, { fg = color, bold = true })
    end
end

local dvd = {
    fps = 16,
    init = function(grid)
        define_highlights()

        local width, height = #grid[1], #grid
        local rows = logo_cells()
        local logo_h = #rows
        local logo_w = #rows[1]

        return {
            rows = rows,
            logo_w = logo_w,
            logo_h = logo_h,
            width = width,
            height = height,
            x = math.random(1, math.max(1, width - logo_w)),
            y = math.random(1, math.max(1, height - logo_h)),
            dx = math.random(0, 1) == 0 and 1 or -1,
            dy = math.random(0, 1) == 0 and 1 or -1,
            color = math.random(1, #COLORS),
        }
    end,
    update = function(grid, state)
        for r = 1, state.height do
            for c = 1, state.width do
                grid[r][c] = { char = " ", hl_group = "" }
            end
        end

        local hl = "ScreensaverDvd" .. state.color
        for r, row in ipairs(state.rows) do
            local gy = state.y + r - 1
            if gy >= 1 and gy <= state.height then
                for c, char in ipairs(row) do
                    local gx = state.x + c - 1
                    if char ~= " " and gx >= 1 and gx <= state.width then
                        grid[gy][gx] = { char = char, hl_group = hl }
                    end
                end
            end
        end

        state.x = state.x + state.dx
        state.y = state.y + state.dy

        local bounced = false
        if state.x <= 1 then
            state.x, state.dx, bounced = 1, 1, true
        elseif state.x + state.logo_w - 1 >= state.width then
            state.x, state.dx, bounced = state.width - state.logo_w + 1, -1, true
        end
        if state.y <= 1 then
            state.y, state.dy, bounced = 1, 1, true
        elseif state.y + state.logo_h - 1 >= state.height then
            state.y, state.dy, bounced = state.height - state.logo_h + 1, -1, true
        end

        if bounced then
            state.color = state.color % #COLORS + 1
        end

        return true
    end,
}

return {
    "Root-lee/screensaver.nvim",
    event = "VeryLazy",
    opts = {
        idle_ms = 5 * 60 * 1000,
        auto_start = true,
        disable_on_focus_lost = true,
        exit_key = "<Esc>",
        animations = { "dvd" },
        winblend = 0,
    },
    config = function(_, opts)
        local anims = require("screensaver.animations")
        local get_animation = anims.get_animation
        anims.get_animation = function(name)
            if name == "dvd" then
                return dvd
            end
            return get_animation(name)
        end

        require("screensaver").setup(opts)
    end,
}
