return {
  {
    "mikesmithgh/kitty-scrollback.nvim",
    enabled = true,
    lazy = true,
    cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
    event = { "User KittyScrollbackLaunch" },
    -- This version is stable for current Kitty versions
    version = "*",
    config = function()
      require("kitty-scrollback").setup()
    end,
  },
}
