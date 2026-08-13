return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "ThePrimeagen/harpoon",
    },
    event = "BufReadPre",
    config = function()

        local function harpoons()
            local ok, harpoon = pcall(require, "harpoon")
            if not ok then return "" end

            local list = harpoon:list()
            if not list then return "" end

            local count = 0
            for i = 1, list:length() do
                if list.items[i] then count = count + 1 end
            end

            return count > 0 and ("󰛢 " .. count) or "" -- 󰀱
        end
    
        require("lualine").setup({
            options = {
                theme = "auto",
                icons_enabled = true,
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = { "alpha", "neo-tree", "lazy" },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics", harpoons },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
            extensions = { "neo-tree", "toggleterm", "lazy" },
        })
    end,
}
