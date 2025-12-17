-- My pure Lua neovim config

require("options")  -- options with Lua table
require("mappings")  -- mapping
require("plugins") -- with lazy.nvim

vim.cmd("colorscheme catppuccin-frappe")
