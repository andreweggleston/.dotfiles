-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "c", "cpp" },
  callback = function()
    vim.b.autoformat = false
  end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.test" },
  callback = function()
    vim.bo.filetype = "test"
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "test" },
  callback = function()
    vim.bo.commentstring = "// %s"
  end,
})
