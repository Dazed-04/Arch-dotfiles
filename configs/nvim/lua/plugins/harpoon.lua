return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup({
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
      },
    })

    -- Register the Harpoon Group for Which-Key
    local wk = require("which-key")
    wk.add({
      { "<leader>h", group = "Harpoon", icon = { icon = "󰀱 ", color = "orange" } },
      -- Define specific icons for n and p to override the group icon
      { "<leader>hn", icon = { icon = "󰮶 ", color = "green" } },
      { "<leader>hp", icon = { icon = "󰮹 ", color = "cyan" } },
      { "<leader>ha", icon = { icon = "󰐕 ", color = "blue" } },
      { "<leader>hc", icon = { icon = "󰛖 ", color = "red" } },
    })

    -- Add current file to Harpoon
    vim.keymap.set("n", "<leader>ha", function()
      harpoon:list():add()
    end, { desc = "Add to harpoon buffer" })

    -- Clear Harpoon Buffer
    vim.keymap.set("n", "<leader>hc", function()
      harpoon:list():clear()
    end, { desc = "Clear Harpoon Buffer" })

    -- Toggle Harpoon Menu
    vim.keymap.set("n", "<C-e>", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)

    -- Move between files using Alt + 1/2/3/4
    for i = 1, 4 do
      vim.keymap.set("n", "<M-" .. i .. ">", function()
        harpoon:list():select(i)
      end, { desc = "Harpoon to Slot " .. i })
    end

    -- Sequential Navigation

    -- Next file
    vim.keymap.set("n", "<leader>hn", function()
      harpoon:list():next()
    end, { desc = "Harpoon: Next" })
    -- Previous file
    vim.keymap.set("n", "<leader>hp", function()
      harpoon:list():prev()
    end, { desc = "Harpoon: Previous" })
  end,
}
