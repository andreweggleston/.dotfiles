-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.o.cursorline = false

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.opt.foldmethod = "indent"
vim.opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"

vim.g.root_spec = { "cwd" }

vim.diagnostic.config({ virtual_lines = { only_current_line = true } })

vim.o.background = "dark"

vim.g.lazyvim_python_lsp = "pyright"
