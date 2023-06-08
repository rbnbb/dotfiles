nnoremap ; :
nnoremap : ;
vnoremap : ;
vnoremap ; :
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
set number
set expandtab
set tabstop=4
set shiftwidth=4
set list
set listchars=tab:>-,nbsp:+
set undodir=~/.vim/undo

call plug#begin()
    Plug 'tpope/vim-commentary'
    Plug 'moll/vim-bbye'
    Plug 'nordtheme/vim'
call plug#end()

colorscheme nord
