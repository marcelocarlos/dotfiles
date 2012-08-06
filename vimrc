" Configuration file for vim
set modelines=0		" CVE-2007-2438

" Toggle for auto-indenting
set pastetoggle=<F2>

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
endif

" Enable line numbers
set number
:nmap <f3> :set invnumber<CR>

" Enable syntax highlighting
syntax on

" Highlight current line
"  set cursorline

" Make tabs as wide as two spaces
set tabstop=4

" Highlight searches
set hlsearch

" Highlight dynamically as pattern is typed
set incsearch

" Always show status line
set laststatus=2

" Enable mouse in all modes
set mouse=a

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
