return {
  {
    "mfussenegger/nvim-jdtls",
    ---@diagnostic disable-next-line: unused-local
    opts = function(_, opts)
      -- Create an autocommand to organize imports before saving
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.java",
        callback = function()
          require("jdtls").organize_imports()
        end,
      })
    end,
  },
}
