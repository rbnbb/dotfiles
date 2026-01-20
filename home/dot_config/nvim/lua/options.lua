-- because nvim-tree replaces this in-build plugging
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- according to https://github.com/Wansmer/nvim-config/blob/main/lua/options.lua
local options = {
    -- ==========================================================================
    -- Indents, spaces, tabulation
    -- ==========================================================================
    expandtab = true,
    autoindent = true,
    smartindent = true,
    smarttab = true,
    shiftwidth = 4,
    tabstop = 4,

    -- ==========================================================================
    -- UI
    -- ==========================================================================
    number = true,
    relativenumber = true,
    termguicolors = true,
    numberwidth = 3,
    showmode = false,
    showcmd = false,
    cmdheight = 1,
    pumheight = 10,
    showtabline = 0,
    cursorline = true,
    signcolumn = "yes",
    scrolloff = 0,
    sidescrolloff = 3,
    colorcolumn = tostring(0),
    laststatus = 3,
    fillchars = {
        eob = " ",
        fold = "⋅",
        foldopen = "",
        foldclose = "",
        foldsep = " ", -- or "│" to use bar for show fold area
        horiz = "─",
        horizup = "┴",
        horizdown = "┬",
        vert = "│",
        vertleft = "┤",
        vertright = "├",
        verthoriz = "┼",
    },
    listchars = {
        tab = ">-",
        nbsp = "+",
        trail = "☯",
    },
    showbreak = "↪",
    title = false,
    -- statuscolumn = require("modules.status").column(),
    -- statusline = require("modules.status").line(),
    -- rule = true,

    -- ==========================================================================
    -- Text
    -- ==========================================================================
    -- textwidth = 128,
    wrap = true,
    linebreak = true,

    -- ==========================================================================
    -- Search
    -- ==========================================================================
    ignorecase = true,
    smartcase = true,
    hlsearch = true,
    infercase = true,

    -- ==========================================================================
    -- Folding
    -- ==========================================================================
    foldcolumn = "0",
    foldlevel = 99,
    foldlevelstart = 99,
    foldenable = true,

    -- ==========================================================================
    -- Other
    -- ==========================================================================
    updatetime = 1000,
    undofile = true,
    undodir = vim.fn.expand("$HOME/.config/nvim/undo"),
    viewdir = vim.fn.expand("$HOME/.local/state/nvim/view"),
    splitright = true,
    splitbelow = true,
    mouse = "a",
    backup = false,
    swapfile = false,
    completeopt = { "menuone", "noselect" },
    winbar = " ",
    spell = true,
    spelllang = "en_us,fr",
    spellsuggest = "9",
    whichwrap = vim.opt.whichwrap:append("<,>,[,],h,l"),
    shortmess = vim.opt.shortmess:append("c"),
    iskeyword = vim.opt.iskeyword:append("-"),
    -- langmap = langmap,
    -- smooth scroll = true,
}

for option_name, value in pairs(options) do
    -- To avoid errors on toggle nvim version
    local ok, _ = pcall(vim.api.nvim_get_option_info2, option_name, {})
    if ok then
        vim.opt[option_name] = value
    else
        vim.notify("Option " .. option_name .. " is not supported", vim.log.levels.WARN)
    end
end

-- vim.cmd([[
-- autocmd InsertEnter * set listchars-=trail:☯
-- autocmd InsertLeave * set listchars+=trail:☯
-- ]])
--
-- remember_folds
-- local folds_augroup = vim.api.nvim_create_augroup("Folds", { clear=true })
-- vim.api.nvim_create_autocmd("BufWritePost", {
--     group = folds_augroup,
--     command = "mkview | filetype detect | set foldmethod=manual"
-- })
-- vim.api.nvim_create_autocmd("QuitPre", {
--     group = folds_augroup,
--     command = "mkview | filetype detect | set foldmethod=manual"
-- })

-- vim.api.nvim_create_autocmd("BufWinEnter", {
--     group = folds_augroup,
--     command = "silent! loadview | filetype detect | set foldmethod=manual | normal! zM"
-- })

-- exclude quickfix from bf, bn
vim.cmd([[
augroup qf
    autocmd!
    autocmd FileType qf set nobuflisted
augroup END
]])

-- remember_folds
vim.cmd [[
augroup remember_folds
  autocmd!
  autocmd BufWinLeave *.* mkview
  autocmd BufWinEnter *.* silent! loadview
augroup END
]]

vim.cmd [[
set viewoptions-=curdir
set viewoptions-=options
]]
