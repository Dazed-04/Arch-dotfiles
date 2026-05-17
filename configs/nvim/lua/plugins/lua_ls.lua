return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                library = {
                  "/usr/share/hypr/stubs/",
                  vim.fn.expand("~/.config/hypr/"),
                },
                checkThirdParty = false,
              },
            },
          },
        },
      },
    },
  },
}
