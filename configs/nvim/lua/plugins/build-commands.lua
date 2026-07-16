-- Usage inside nvim:
--   :Go        -> builds current Go module, opens quick fix on error
--   :Gorun -> builds + runs current Go module
--   :C         -> compiles current C file, opens quickfix on error

return {
  {
    dir = vim.fn.stdpath("config"), -- dummy plugin spec just to host the setup function
    name = "build-commands",
    config = function()
      -- ============================================================
      -- GO
      -- ============================================================
      vim.api.nvim_create_user_command("Go", function()
        vim.cmd("compiler go")
        vim.opt.makeprg = "go build ./..."
        vim.cmd("make")
        vim.cmd("copen")
      end, { nargs = 0 })

      vim.api.nvim_create_user_command("Gorun", function()
        vim.cmd("compiler go")
        vim.opt.makeprg = "go build ./..."
        vim.cmd("make")
        vim.cmd("copen")
        -- Only run if build succeeded (quickfix list empty)
        if #vim.fn.getqflist() == 0 then
          vim.cmd("cclose")
          vim.cmd("split | terminal go run .")
        end
      end, { nargs = 0 })

      -- ============================================================
      -- C
      -- ============================================================
      vim.api.nvim_create_user_command("C", function()
        vim.cmd("compiler gcc")
        -- %:t:r = current filename without extension, used as output binary name
        vim.opt.makeprg = "gcc -Wall -g -o %:t:r %"
        vim.cmd("make")
        vim.cmd("copen")
      end, { nargs = 0 })

      vim.api.nvim_create_user_command("Crun", function()
        vim.cmd("compiler gcc")
        vim.opt.makeprg = "gcc -Wall -g -o %:t:r %"
        vim.cmd("make")
        vim.cmd("copen")
        if #vim.fn.getqflist() == 0 then
          vim.cmd("cclose")
          vim.cmd("split | terminal ./%:t:r")
        end
      end, { nargs = 0 })

      -- ============================================================
      -- C++
      -- ============================================================
      vim.api.nvim_create_user_command("Cpp", function()
        vim.cmd("compiler gcc") -- g++ output format matches gcc's errorformat fine
        vim.opt.makeprg = "g++ -Wall -g -std=c++20 -o %:t:r %"
        vim.cmd("make")
        vim.cmd("copen")
      end, { nargs = 0 })

      vim.api.nvim_create_user_command("Cpprun", function()
        vim.cmd("compiler gcc")
        vim.opt.makeprg = "g++ -Wall -g -std=c++21 -o %:t:r %"
        vim.cmd("make")
        vim.cmd("copen")
        if #vim.fn.getqflist() == 0 then
          vim.cmd("cclose")
          vim.cmd("split | terminal ./%:t:r")
        end
      end, { nargs = 0 })
    end,
  },
}
