return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>ff", false },
      { "<leader>sf", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
    },
    opts = {
      dashboard = { enabled = false },
      picker = {
        sources = {
          files = {
            hidden = true,
            ignored = true,
            exclude = { "node_modules" },
          },
        },
      },
    },
  },
}
