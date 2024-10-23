nnoremap ; :
nnoremap : ;
vnoremap : ;
vnoremap ; :
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
nnoremap <space>j :w<CR>
nnoremap <space>h :bn<CR>
nnoremap <space>l :bp<CR>
set number
set expandtab
set tabstop=4
set shiftwidth=4
set list
set listchars=tab:>-,nbsp:+
set undodir=~/.vim/undo
set laststatus=2
set statusline=%f
set statusline+=%m
if &diff
    colorscheme desert
endif

call plug#begin()
    Plug 'tpope/vim-commentary'
    Plug 'moll/vim-bbye'
    Plug 'nordtheme/vim'
    Plug 'nordtheme/vim'
    Plug 'JuliaEditorSupport/julia-vim'
call plug#end()

colorscheme nord
let g:nord_uniform_diff_background=1
