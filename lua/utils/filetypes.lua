local M = {}

M.panels = {
    "aerial",
    "alpha",
    "checkhealth",
    "copilot",
    "copilot-chat",
    "dap-repl",
    "dapui",
    "dapui_breakpoints",
    "dapui_console",
    "dapui_scopes",
    "dapui_stacks",
    "dapui_watches",
    "dashboard",
    "DressingSelect",
    "fugitive",
    "gitcommit",
    "help",
    "lazy",
    "lspinfo",
    "man",
    "mason",
    "neo-tree",
    "neominimap",
    "neotest-summary",
    "noice",
    "notify",
    "notifydetails",
    "NvimTree",
    "Outline",
    "qf",
    "spectre",
    "spectre_panel",
    "TelescopePrompt",
    "TelescopeResults",
    "toggleterm",
    "Trouble",
    "trouble",
    "typr",
    "undotree",
}

local lookup = {}
for _, ft in ipairs(M.panels) do
    lookup[ft] = true
end

function M.contains(ft)
    return ft ~= nil and lookup[ft] == true
end

function M.with(extra)
    return vim.list_extend(vim.deepcopy(M.panels), extra or {})
end

return M
