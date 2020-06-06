" call plug#begin(expand('~/.vim/plugged'))
" 
" 
" 
" 
" call plug#end()

" visual
syntax on
set ruler
set number
set title
set titlestring=nvim-%F
set t_Co=256
set cursorline
set background=dark " for the dark version

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

colorscheme torte
set background=dark
hi statusline ctermfg=234 ctermbg=250
hi LineNr ctermfg=246

