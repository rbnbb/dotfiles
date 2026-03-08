-- Settings for vimtex
vim.g.tex_flavor = 'lualatex'
vim.g.vimtex_complete_enabled = 0
vim.g.vimtex_fold_enabled = 1
vim.g.vimtex_quickfix_mode = 0
vim.g.tex_conceal = 'abdmg'
vim.g.vimtex_quickfix_ignore_filters = { 'Overfull', 'Underfull', 'float specifier' }
vim.g.vimtex_compiler_latexmk = {
    options = {
        '--shell-escape',
        '-verbose',
        '-file-line-error',
        '-synctex=1',
        '-interaction=nonstopmode',
    },
}

local os_name = vim.uv.os_uname().sysname
if os_name == 'Linux' then
    vim.g.vimtex_view_general_viewer = 'okular'
    vim.g.vimtex_view_general_options = [[--unique file:@pdf\#src:@line@tex]]
    vim.g.vimtex_view_mupdf_options = '@pdf'
elseif os_name == 'Darwin' then
    vim.g.vimtex_view_method = 'sioyek'
end
