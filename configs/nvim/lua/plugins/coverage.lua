config = function()
  require("coverage").setup({
    auto_reload = true,
    -- This is the part that enables full line highlights
    highlights = {
      covered = { fg = "#C3E88D" }, -- You can adjust colors to match Gruvbox
      uncovered = { fg = "#F07178" },
    },
    -- Use this to ensure the signs (gutter) and highlights coexist
    signs = {
      covered = { hl = "CoverageCovered", text = "▎" },
      uncovered = { hl = "CoverageUncovered", text = "▎" },
    },
    -- Enable line highlights
    line_highlights = true,
  })
end
