-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Escape any terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- Jump into a floating window (Eval, Hover, etc.)
vim.keymap.set("n", "<leader>ww", function()
  local found_float = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      vim.api.nvim_set_current_win(win)
      found_float = true
      break
    end
  end
  if not found_float then
    print("No floating window found")
  end
end, { desc = "Focus floating window" })

-- Force a true floating terminal on Ctrl+/
vim.keymap.set("n", "<C-/>", function()
  Snacks.terminal.toggle(
    nil,
    { id = "scratchpad", win = { position = "float", border = "rounded", width = 0.8, height = 0.8 } }
  )
end, { desc = "Floating Terminal (Root Dir)" })

-- Ensure it works from Terminal mode too
vim.keymap.set("t", "<C-/>", function()
  Snacks.terminal.toggle()
end, { desc = "Hide Terminal" })
