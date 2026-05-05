return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>ff", false },
      { "<leader>sf", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
    },
    opts = {
      picker = {
        sources = {
          files = {
            hidden = true,
          },
        },
      },
    },
  },
}
