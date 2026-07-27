return {
  "brianhuster/live-preview.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {},
  keys = {
    { "<leader>cp", "<cmd>LivePreview start<cr>", desc = "Start Live Preview" },
    { "<leader>cP", "<cmd>LivePreview close<cr>", desc = "Stop Live Preview" },
  },
}
