source ~/vimconfigbase.vim

" Automate plug.vim installation:
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

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
set clipboard=unnamedplus
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

" tab to translate into 2 spaces
set shiftwidth=2

set termguicolors

colorscheme space-vim-dark
"colorscheme gruvbox
set background=dark
highlight normal ctermbg=0 guibg=#000000
