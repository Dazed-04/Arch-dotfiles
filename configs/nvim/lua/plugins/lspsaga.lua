return {
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    config = function()
      require("lspsaga").setup({
        ui = {
          border = "rounded",
          devicon = true,
          title = true,
          expand = "⊞",
          collapse = "⊟",
          code_action = "💡",
        },
      })
    end,
    keys = {
      -- 1. Standard Saga Keybinds
      { "gp", "<cmd>Lspsaga peek_definition<cr>", desc = "Peek Definition (Inlay)" },
      { "gh", "<cmd>Lspsaga hover_doc<cr>", desc = "Hover Doc" },

      -- 2. Vertical Split
      {
        "gv",
        function()
          local params = vim.lsp.util.make_position_params(0, "utf-16")
          vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result)
            if result == nil or vim.tbl_isempty(result) then
              vim.notify("Definition not found", vim.log.levels.WARN)
              return
            end

            local def = result[1] or result
            local uri = def.uri or def.targetUri
            local target_file = vim.uri_to_fname(uri)
            local current_file = vim.api.nvim_buf_get_name(0)

            if target_file ~= current_file then
              vim.cmd("vsplit " .. target_file)
              local range = def.range or def.targetSelectionRange
              vim.api.nvim_win_set_cursor(0, { range.start.line + 1, range.start.character })
              vim.cmd("normal! zz")
            else
              -- Defensive check for swapfile prevention
              vim.notify("Aborted: Definition is in the current file. Swapfile risk!", vim.log.levels.ERROR)
            end
          end)
        end,
        desc = "Smart V-Split (No Swapfile)",
      },
    },
  },
}
