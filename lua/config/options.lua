-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.showtabline = 0

-- Use basedpyright (pyright fork) as the Python LSP instead of the default pyright.
vim.g.lazyvim_python_lsp = "basedpyright"
