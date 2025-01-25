" visual
syntax on
set ruler
set number
set title
set titlestring=nvim-%F
set t_Co=256
set cursorline

" abbreviations
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall
cnoreabbrev Qa qa

"" Switching windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

"" esc mapping
inoremap jk <ESC>
tnoremap jk <C-\><C-n>

" scroll
set scrolloff=5               " keep at least 5 lines above/below
set sidescrolloff=5           " keep at least 5 lines left/right

" line length
" set textwidth=80

" toggle for paste mode
set pastetoggle=<F3>

" set ignorecase  " do case insensitive search 
set incsearch   " show incremental search results as you type

" disable mouse
set mouse=
