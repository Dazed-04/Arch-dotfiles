return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- 1. Enable inlay hints globally at the start
      inlay_hints = {
        enabled = true,
        exclude = { "vue" },
      },
      servers = {
        hyprls = {},
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
                inlay_hints = {
                  variableTypes = true,
                  callArgumentNames = true,
                  functionReturnTypes = true,
                  genericTypes = true,
                },
              },
            },
          },
        },
        clangd = {
          keys = {
            { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C++)" },
          },
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
          settings = {
            clangd = {
              InlayHints = {
                Designators = true,
                Enabled = true,
                ParameterNames = true,
                DeducedTypes = true,
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              hint = {
                enable = true,
                paramName = "All", -- Shows the name of the parameter in function calls
                setType = true, -- Shows types when assigning variables
                paramType = true, -- Shows types in function definitions
                arrayIndex = "Disable",
              },
            },
          },
        },
        -- 3. You can add others here easily
        -- clangd = {},
        -- basedpyright = {},
      },
      -- 4. This setup function ensures the hints are turned on when the LSP attaches
      setup = {
        ["*"] = function(_, opts)
          -- This is the 'Force Enable' for all servers
          vim.lsp.inlay_hint.enable(true)
        end,
      },
    },
  },
}
