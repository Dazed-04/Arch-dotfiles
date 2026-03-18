-- Force Neovim to acknowledge the site directory for both runtime and C-binaries (.so)
local site_path = "/home/Dazed/.local/share/nvim/site"
if not vim.tbl_contains(vim.api.nvim_list_runtime_paths(), site_path) then
  vim.opt.rtp:prepend(site_path)
end
--bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
