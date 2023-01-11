source ~/vimconfigbase.vim

call plug#begin(expand('~/.vim/plugged'))

nnoremap <Space> <nop>
let mapleader = "\<Space>"
let g:mapleader = "\<Space>"
let maplocalleader =  "\<Space>"

Plug 'liuchengxu/space-vim-dark'
Plug 'morhetz/gruvbox'
Plug 'rakr/vim-one'

" Plug 'godlygeek/tabular'
" Plug 'preservim/vim-markdown'

" focus mode
Plug 'junegunn/goyo.vim'

" vimwiki
Plug 'vimwiki/vimwiki'

call plug#end()


" copy&paste from system clipboard
vnoremap  <leader>y  "+y
vnoremap  <leader>p  "+p

" next 3 lines are needed for vimwiki
set nocompatible
filetype plugin on
syntax on
" vimwiki with markdown
let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
" prevent vimwiki of setting conceallevel=2:
let g:vimwiki_conceallevel=2

" to allow backspacing over everything in insert mode
set backspace=indent,eol,start

set termguicolors

colorscheme space-vim-dark
"colorscheme gruvbox
set background=dark
highlight normal ctermbg=0 guibg=#000000
