-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- pane management
vim.keymap.set("n", "|", "<cmd>vsplit<cr>")
vim.keymap.set("n", "\\", "<cmd>split<cr>")

-- close buffer
vim.keymap.set("n", "<leader>c", Snacks.bufdelete.delete)

-- save and quit
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")

-- better git diagnostics
vim.keymap.set("n", "<leader>gL", function()
  LazyVim.lazygit({ args = { "log" }, cwd = LazyVim.root.git() })
end, { desc = "Lazygit Log" })

vim.keymap.set("n", "<leader>gl", function()
  package.loaded.gitsigns.blame_line()
end, { desc = "Blame Line" })

-- doge replacement
vim.keymap.set("n", "<leader>D", "<cmd>Neogen<cr>")

-- moving the c mappings to C
vim.keymap.set({ "n", "v" }, "<leader>Cf", function()
  LazyVim.format({ force = true })
end, { desc = "Format" })
vim.keymap.set("n", "<leader>Cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

vim.keymap.set("n", "<leader>;", require("lsp_lines").toggle, { desc = "Toggle lsp_lines" })

-- remove the keymaps I don't like
vim.keymap.del("n", "<leader>cd")
vim.keymap.del("n", "<leader>cf")
vim.keymap.del("n", "<leader>fn")
vim.keymap.del("n", "<leader>ft")
vim.keymap.del("n", "<leader>fT")
vim.keymap.del("n", "<leader>|")
vim.keymap.del("n", "<leader>-")

