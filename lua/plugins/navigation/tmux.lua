return {
    "christoomey/vim-tmux-navigator",
    cmd = {
        "TmuxNavigateLeft",
        "TmuxNavigateDown",
        "TmuxNavigateUp",
        "TmuxNavigateRight",
        "TmuxNavigatePrevious",
        "TmuxNavigatorProcessList",
    },
    keys = {
        { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to left window/pane" },
        { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to below window/pane" },
        { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to above window/pane" },
        { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to right window/pane" },
        { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Go to previous window/pane" },
    },
}
