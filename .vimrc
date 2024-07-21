" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible

filetype indent plugin on
 
" Enable syntax highlighting
syntax on

 
" Better command-line completion
set wildmenu
  
" Show partial commands in the last line of the screen
set showcmd
   
" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
"   " mapping of <C-L> below)
set hlsearch

" Display line numbers on the left
set number
syntax enable           " enable syntax processing
colorscheme industry
