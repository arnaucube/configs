call plug#begin(expand('~/.vim/plugged'))

Plug 'scrooloose/nerdtree'
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1

"" Color
Plug 'tomasr/molokai'
Plug 'morhetz/gruvbox'
Plug 'srcery-colors/srcery-vim'

call plug#end()

" visual
syntax on
set ruler
set number
set title
set titlestring=vim-%F
set t_Co=256
set cursorline
set background=dark " for the dark version

if $COLORTERM == 'gnome-terminal'
  set term=gnome-256color
else
  if $TERM == 'xterm'
    set term=xterm-256color
  endif
endif

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


colorscheme gruvbox

let &t_SI.="\e[6 q" "SI = INSERT mode
let &t_SR.="\e[4 q" "SR = REPLACE mode
let &t_EI.="\e[2 q" "EI = NORMAL mode (ELSE)

