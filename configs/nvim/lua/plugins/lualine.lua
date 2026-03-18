return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    local function harpoon_status()
      local harpoon = require("harpoon")
      local list = harpoon:list()
      local curr_file = vim.api.nvim_buf_get_name(0)
      local cwd = vim.uv.cwd()

      for i = 1, list:length() do
        local item = list:get(i)
        if item and item.value ~= "" then
          local full_item_path = vim.fs.normalize(cwd .. "/" .. item.value)
          local full_curr_path = vim.fs.normalize(curr_file)

          if full_item_path == full_curr_path then
            return "󰀱 " .. i .. "/" .. list:length()
          end
        end
      end
      return ""
    end
    -- Add to the right side of the status bar
    table.insert(opts.sections.lualine_x, {
      harpoon_status,
      color = { fg = "#ff9e64", gui = "bold" },
      on_click = function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
    })
  end,
}
