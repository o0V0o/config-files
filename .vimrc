set nocompatible

set rtp^=~/.vim/glsl.vim/

filetype plugin on
filetype indent on
syntax on

"set the location of help files
helptags $HOME/.vim/doc/

if has("win16") || has("win32") || has("win64")
	set backupdir =$VIM\vimfiles\backupdir
else
	set backupdir =$HOME/.vimbackup
	set dictionary =$HOME/.vim/dictionary/english.list
endif
set backup
set noswapfile 

set visualbell


set tabstop=4 " 4 spaces per tab
set shiftwidth=4 " spaces for each tab used by autoindent
set smarttab " turn on auto indent
set autoindent " turn on auto indent! (copy indent from previous line)
"set autoindent smartindent


set backspace=indent,eol,start "backspace over everything
set showcmd  " show partial command in status bar
set number " enable line numbers
set ruler " show column and line number of cursor
set mouse=a " Use the mouse!
set background=light " vim uses colors that look good on a dark background

set textwidth=79 " text longer than this is autowrapped
set formatoptions=cq 	" c = auto-wrap comments with new lines and insert comment headers
				" q = allow formatting of comments with 'gq'
				" r = automaticly add comment leader after hitting return in insert mode
				" t = autowrap text using textwidth (does not apply to comments)
set formatoptions-=o
set formatoptions-=r

set showmatch " when a bracket is insterted jump to matching brackets
set incsearch " show matches as a search is being typed
set hlsearch " highlight previous search matches

set ignorecase " ignore case in searches
set smartcase " use case sensitive searches if capital letters are used

set ttyfast " we have a fast tty..

highlight MatchParen ctermbg=blue guibg=lightyellow
au BufNewFile,BufRead *.frag,*.vert,*.fs,*.vs,*.glsl set filetype=glsl

let mapleader =";"
" make it easy to add things to our vimrc!
nnoremap <leader>ev :hsplit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

"copy across sessions using a tmp file
nnoremap <leader>y :'a'b w! /tmp/vitmp<CR>
vnoremap <leader>y :w! /tmp/vitmp<CR> 
nnoremap <leader>p :r! cat /tmp/vitmp<CR>

" Autocomplete macros:
"inoremap ( ()<Left>
"inoremap [ []<Left>
""inoremap { {}<Left>
""inoremap () ()
""inoremap [] [] 
""inoremap {} {}

""vnoremap ( s()<Esc>P<Right>%
""vnoremap [ s[]<Esc>P<Right>%
""vnoremap { s{}<Esc>P<Right>%

""vnoremap ) s(<Space><Space>)<Esc><Left>P<Right><Right>%
""vnoremap ] s[<Space><Space>]<Esc><Left>P<Right><Right>%
""vnoremap } s{<Space><Space>}<Esc><Left>P<Right><Right>%

""inoremap ' ''<Left>
""inoremap " ""<Left>
""inoremap '' ''
""inoremap "" ""

""xnoremap ' s''<Esc>P<Right>
""xnoremap " s""<Esc>P<Right>
""xnoremap ` s``<Esc>P<Right>

" Lua-support plugin:

"let g:Lua_LoadMenus = 'auto'
"let g:LuarootMenu   = '&lua'
"let g:Lua_Executable = 'lua'
"let g:Lua_CompilerExec = "luac"
"let g:Lua_CompiledExtension = "luac"
