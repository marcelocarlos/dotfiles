" ------------------------------------------------
" Plugins
" ------------------------------------------------
call plug#begin('~/.config/nvim/plugged')

" General
Plug 'benekastah/neomake'
" Plug 'Raimondi/delimitMate'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'ervandew/supertab'
Plug 'tomasr/molokai'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'zchee/deoplete-jedi'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'joshdick/onedark.vim'
"Plug 'fishbullet/deoplete-ruby'

call plug#end()

" -------------------------------------------------
" Settings
" -------------------------------------------------
" enable syntax highlighting
syntax on filetype plugin indent on

" Dark background
set background=dark

" line numbers
set number

" linebreaks
set linebreak

" toggle autoindent
set autoindent

" more powerful backspacing
set backspace=indent,eol,start

" Enhance command-line completion
set wildmenu

" Highlight current line
set cursorline

" Make tabs as wide as four spaces
set smarttab
set tabstop=4
set shiftwidth=4
set expandtab

" Show the cursor position
set ruler

" Add a 80 char column marker
if version >= 703
    set colorcolumn=80
endif

" Don’t show the intro message when starting vim
set shortmess=atI

" Show the filename in the window titlebar
set title

" Show the (partial) command as it’s being typed
set showcmd

" Show invisibles
set list lcs=trail:·,tab:»·,nbsp:·

" Do not change to Visual Mode when selecting text using mouse
set mouse-=a

" utf8 enconding
set encoding=utf-8

" Plugin benekastah/neomake config
" enable lint on save
autocmd! BufWritePost * Neomake

" molokai color scheme
"colorscheme molokai
set termguicolors
colorscheme onedark

" Use deoplete.
let g:deoplete#enable_at_startup = 1

" Powerline fonts for vim-airline
let g:airline_powerline_fonts = 1

" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1

" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

" Open a NERDTree automatically when vim starts up
"autocmd vimenter * NERDTreeTabsOpen
" Toggle nerdtree with Ctrl+/
map <C-_> :NERDTreeTabsToggle<CR>
" Close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Open NERDTree automatically when vim starts up on opening a directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
" Open a NERDTree automatically when vim starts up if no files were specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" esc esc to leave terminal mode
tnoremap <esc><esc> <C-\><C-n>

" Using buffers properly
" This allows buffers to be hidden if you've modified a buffer.
set hidden
command Bq bp <BAR> bd #
command Bnew enew
command Bn bnext
command Bp bprevious
command Bl ls
" Alternate buffers with \<number>
" \l       : list buffers
" \b \f \g : go back/forward/last-used
" \1 \2 \3 : go to buffer 1/2/3 etc
nnoremap <Leader>l :ls<CR>
nnoremap <Leader>b :bp<CR>
nnoremap <Leader>f :bn<CR>
nnoremap <Leader>g :e#<CR>
nnoremap <Leader>q :Bq<CR>
nnoremap <Leader>1 :1b<CR>
nnoremap <Leader>2 :2b<CR>
nnoremap <Leader>3 :3b<CR>
nnoremap <Leader>4 :4b<CR>
nnoremap <Leader>5 :5b<CR>
nnoremap <Leader>6 :6b<CR>
nnoremap <Leader>7 :7b<CR>
nnoremap <Leader>8 :8b<CR>
nnoremap <Leader>9 :9b<CR>
nnoremap <Leader>0 :10b<CR>

" jk to <esc>
:inoremap jk <esc>
