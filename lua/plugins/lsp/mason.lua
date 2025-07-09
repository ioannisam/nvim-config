return {
    "williamboman/mason.nvim",
    config = function()
        require("mason").setup({
            ui = {
                check_outdated_packages_on_open = true,
                border = "rounded",
                backdrop = 60,
                width = 0.8,
                height = 0.9,

                icons = {
                    package_installed = "✓", 
                    package_pending = "↻ ",
                    package_uninstalled = "×",
                },

                keymaps = {
                    toggle_package_expand = "<CR>",
                    install_package = "i",
                    update_package = "u",
                    check_package_version = "c",
                    update_all_packages = "U",
                    check_outdated_packages = "C",
                    uninstall_package = "X",
                    cancel_installation = "<C-c>",
                    apply_language_filter = "<C-f>",
                    toggle_package_install_log = "l",
                    toggle_help = "h",
                },
            },
        })
    end,
}
