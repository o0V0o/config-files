


set tabstop=4 " 4 spaces per tab
set shiftwidth=4 " spaces for each tab used by autoindent
set smarttab " turn on auto indent
set autoindent " turn on auto indent! (copy indent from previous line)
"set autoindent smartindent

set showcmd  " show partial command in status bar
set number " enable line numbers
set ruler " show column and line number of cursor
set background=light " vim uses colors that look good on a dark background
set mouse=a " Use the mouse!

set textwidth=79 " text longer than this is autowrapped
set formatoptions=c,q,t 	" c = auto-wrap comments with new lines and insert comment headers
				" q = allow formatting of comments with 'gq'
				" r = automaticly add comment leader after hitting return in insert mode
				" t = autowrap text using textwidth (does not apply to comments)

set showmatch " when a bracket is insterted jump to matching brackets
set incsearch " show matches as a search is being typed
set hlsearch " highlight previous search matches
set ignorecase " ignore case in searches
set smartcase " use case sensitive searches if capital letters are used

set ttyfast " we have a fast tty..


filetype plugin indent on
syntax on
