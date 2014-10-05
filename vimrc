" Enable Pathogen
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

" Configuration file for vim
set modelines=0		" CVE-2007-2438

" Use the OS clipboard by default (on versions compiled with `+clipboard`)
set clipboard=unnamed
" set clipboard+=unnamed
" set clipboard=autoselect

" Toggle for auto-indenting
set autoindent 
"set smartindent 
set pastetoggle=<F5>

" Make vim more useful
set nocompatible

" more powerful backspacing
set backspace=2		

" Enhance command-line completion
set wildmenu

" Allow cursor keys in insert mode
set esckeys

" Optimize for fast terminal connections
set ttyfast

" Add the g flag to search/replace by default
set gdefault

" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
	set undodir=~/.vim/undo
    silent !mkdir ~/.vim/undo > /dev/null 2>&1
endif
silent !mkdir ~/.vim/backups > /dev/null 2>&1
silent !mkdir ~/.vim/swaps > /dev/null 2>&1

" Enable line numbers
set number
" toggle for show/hide line numbers
:nmap <f6> :set invnumber<CR>

" Enable syntax highlighting
syntax on

" Highlight current line
set cursorline

" Make tabs as wide as four spaces
set tabstop=4 shiftwidth=4 expandtab

" Highlight searches
set hlsearch

" Highlight dynamically as pattern is typed
set incsearch

" Always show status line
set laststatus=2

" Enable mouse in all modes
" set mouse=a
" Do not change to Visual Mode when selecting text using mouse
set mouse-=a

" Disable error bells
set noerrorbells

" Don’t reset cursor to start of line when moving around.
set nostartofline

" Show the cursor position
set ruler

" Don’t show the intro message when starting vim
set shortmess=atI

" Show the current mode
set showmode

" Show the filename in the window titlebar
set title

" Show the (partial) command as it’s being typed
set showcmd

" use the file type plugins
filetype plugin on      

" Save a file as root when using :W
command W w !sudo tee % >/dev/null

" Colorscheme
colorscheme molokai

" omni completion
filetype plugin on
"set omnifunc=syntaxcomplete#Complete
let g:SuperTabDefaultCompletionType = "\<c-x>\<c-o>" 
"let g:SuperTabDefaultCompletionType = "context"

autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

au BufReadPost Vagrantfile set syntax=ruby

set colorcolumn=80

" check syntax on open
let g:syntastic_check_on_open=1

let g:syntastic_error_symbol = 'E→'
let g:syntastic_style_error_symbol = 'S→'
let g:syntastic_warning_symbol = 'W→'
let g:syntastic_style_warning_symbol = '~S'

" allow transparency from terminal
hi Normal ctermfg=252 ctermbg=none
