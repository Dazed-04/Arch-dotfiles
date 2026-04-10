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
    })
  end,
}
