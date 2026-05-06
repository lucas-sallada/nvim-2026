return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        -- The LazyVim Kotlin extra wires up the older fwcd kotlin_language_server.
        -- We disable it and use the official JetBrains kotlin_lsp instead.
        kotlin_language_server = false,
        kotlin_lsp = {
          cmd = { "kotlin-lsp", "--stdio" },
        },
      },
    },
  },
}
