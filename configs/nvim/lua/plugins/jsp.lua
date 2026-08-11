return {
  -- Ensure Treesitter parsers for underlying JSP languages
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "html", "java", "xml" })
      end
    end,
  },

  -- Treat JSP files properly in LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {
          filetypes = { "html", "jsp" },
        },
      },
    },
  },
}
