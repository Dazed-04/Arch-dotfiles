return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      sqls = {
        settings = {
          sqls = {
            connections = {
              {
                driver = "oracle",
                dataSourceName = "scott/tiger@localhost:1521/XEPDB1",
              },
            },
          },
        },
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      },
    },
  },
}
