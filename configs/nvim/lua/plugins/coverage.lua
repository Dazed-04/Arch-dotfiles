return {
  "andythigpen/nvim-coverage",
  dependencies = "nvim-lua/plenary.nvim",
  config = function()
    require("coverage").setup({
      auto_reload = true,
      lang = {
        go = {
          coverage_file = "coverage.out",
        },
      },
      -- This enables the background highlights you wanted
      line_highlights = true,
      highlights = {
        -- Linking to Gruvbox colors (or your own hex codes)
        covered = { fg = "#a9b665" }, -- Greenish
        uncovered = { fg = "#ea6962" }, -- Reddish
      },
    })
  end,
}
