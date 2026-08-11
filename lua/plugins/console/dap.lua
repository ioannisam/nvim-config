return {
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = {
            "mfussenegger/nvim-dap",
            "mason-org/mason.nvim",
        },
        config = function()
            require("mason-nvim-dap").setup({
                ensure_installed = { "codelldb" },
                automatic_installation = true,
            })
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        event = "VeryLazy",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
            "mason-org/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            dapui.setup()

            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            dap.adapters.codelldb = {
                type = 'server',
                port = "${port}",
                executable = {
                    command = vim.fn.stdpath("data") .. '/mason/packages/codelldb/extension/adapter/codelldb',
                    args = { "--port", "${port}" },
                }
            }

            dap.configurations.c = {
                {
                    name = "Launch C program",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                },
            }

            dap.configurations.cpp = vim.deepcopy(dap.configurations.c)
            dap.configurations.rust = vim.deepcopy(dap.configurations.c)

            local map = vim.keymap.set
            map("n", "<F5>", require("dap").continue, { desc = "DAP continue" })
            map("n", "<F9>", require("dap").toggle_breakpoint, { desc = "Toggle breakpoint" })
            map("n", "<F10>", require("dap").step_over, { desc = "Step over" })
            map("n", "<F11>", require("dap").step_into, { desc = "Step into" })
            map("n", "<F12>", require("dap").step_out, { desc = "Step out" })
            map("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
            map("n", "<leader>de", dapui.eval, { desc = "Evaluate expression" })
            vim.keymap.set("n", "<leader>dq", function()
                require("dap").terminate()
                require("dapui").close()
                -- require("dap").clear_breakpoints()
            end, { desc = "Quit DAP session" })
        end,
    },
}
