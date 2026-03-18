return {
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = true,
        force_max_extmark_area = true,
        doc = {
          -- This is the "stickiness" killer.
          -- Setting inline to false stops it from auto-rendering on load.
          inline = false,
          -- This allows the image to "float" or pop up when your cursor is over the link.
          float = true,
          -- Adjust this if the image is too small/large due to your 1.12 scale
          max_width = 50,
          max_height = 40,
        },
      },
      markdown = {
        image = {
          -- "cursor" means it only shows when the cursor is on the line
          -- "hover" is also an option if you prefer it only on deliberate hover
          enabled = true,
          render = "both",
          on_cursor = true,
          inline = false,
        },
      },
      statuscolumn = { enabled = true },
      -- This handles the 'ghost' preview when hovering over a link
      words = { enabled = true },
      dashboard = {
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
    },
  },
}
