-- Settings for vimtex
vim.cmd([[
let g:tex_flavor='lualatex'
let g:vimtex_complete_enabled=0
let g:vimtex_fold_enabled=1
let g:vimtex_quickfix_mode=0
let g:tex_conceal='abdmg'
let g:vimtex_quickfix_ignore_filters = [ 'Overfull', 'Underfull', 'float specifier' ]
let g:vimtex_compiler_latexmk = {
    \ 'options' : [
    \   '--shell-escape',
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \ ],
    \}
]])

local os_name = vim.loop.os_uname().sysname
if os_name == 'Linux' then
    vim.cmd([[
        let g:vimtex_view_general_viewer = 'okular'
        let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
        let g:vimtex_view_mupdf_options='@pdf'
    ]])
elseif os_name == 'Darwin' then
    vim.cmd([[
        let g:vimtex_view_method = 'sioyek'
    ]])
end

