source ~/vimconfigbase.vim

call plug#begin(expand('~/.vim/plugged'))

Plug 'liuchengxu/space-vim-dark'

call plug#end()


set termguicolors

colorscheme space-vim-dark
set background=dark
highlight normal ctermbg=0 guibg=#000000
