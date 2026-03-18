return {
  -- 1. High-Contrast Gruvbox Material
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background = "hard"
      vim.g.gruvbox_material_foreground = "material"
      vim.g.gruvbox_material_transparent_background = 0
      vim.g.gruvbox_material_ui_contrast = "high"

      vim.cmd.colorscheme("gruvbox-material")

      -- APPLY YOUR CUSTOM FIXES HERE
      local colors = {
        bg_dark = "#080808",
        bg_float = "#050505",
        gold = "#d8a657",
        red = "#ef596f",
        fg = "#ebdbb2",
        selection = "#3c3836",
        ft_dark = "#161616",
      }

      -- High-contrast line numbers
      vim.api.nvim_set_hl(0, "LineNr", { fg = colors.gold, bold = true })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = colors.red, bold = true })

      vim.api.nvim_set_hl(0, "Normal", { bg = colors.bg_dark })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = colors.bg_float })

      ---------------------------------------------------------
      -- SAGA THEME FIX (Add these lines)
      ---------------------------------------------------------
      -- The main background of the peek window
      vim.api.nvim_set_hl(0, "SagaNormal", { bg = colors.bg_float })
      -- The rounded border colored with your custom gold
      vim.api.nvim_set_hl(0, "SagaBorder", { fg = colors.gold, bg = colors.bg_float })
      -- Title colors for the peek window
      vim.api.nvim_set_hl(0, "SagaFileName", { fg = colors.gold, bold = true })
      vim.api.nvim_set_hl(0, "SagaFolderName", { fg = colors.fg })
      -- Hover/Documentation styling
      vim.api.nvim_set_hl(0, "SagaDoc", { bg = colors.bg_float })
      ---------------------------------------------------------

      -- Make visual mode translucent
      vim.api.nvim_set_hl(0, "Visual", { bg = colors.selection, blend = 20 })

      -- Make the CursorLine non opaque
      vim.api.nvim_set_hl(0, "CursorLine", { bg = "none", underline = false })

      -- Footer (Statusline) Transparency Fix
      vim.api.nvim_set_hl(0, "StatusLine", { bg = colors.ft_dark, fg = colors.fg })
      vim.api.nvim_set_hl(0, "StatusLineNC", { bg = colors.ft_dark, fg = "#928374" })
    end,
  },

  -- 2. Ensure LazyVim targets the new theme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox-material",
    },
  },

  -- 3. Update Lualine (The Footer)
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.theme = "gruvbox-material"
      opts.options.globalstatus = true
      -- Remove separators to keep the transparent look clean
      opts.options.component_separators = { left = "", right = "" }
      opts.options.section_separators = { left = "", right = "" }
    end,
  },
}
