source ~/vimconfigbase.vim

call plug#begin(expand('~/.config/nvim/plugged'))

nnoremap <Space> <nop>
let mapleader = "\<Space>"
let g:mapleader = "\<Space>"
let maplocalleader =  "\<Space>"

" nerdtree
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'scrooloose/nerdcommenter'

" vim-airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" vim-ripgrep
Plug 'jremmen/vim-ripgrep'

Plug 'airblade/vim-gitgutter'
Plug 'Raimondi/delimitMate'
Plug 'majutsushi/tagbar'

" rainbow parentheses
Plug 'luochen1990/rainbow'

" git
Plug 'tpope/vim-fugitive'

" go
Plug 'fatih/vim-go' " Amazing combination of features.
Plug 'godoctor/godoctor.vim' " Some refactoring tools

" rust
Plug 'rust-lang/rust.vim'
" set hidden
let g:rustfmt_fail_silently = 0
let g:rustfmt_autosave = 1

" javascript
Plug 'jelera/vim-javascript-syntax'

" python
Plug 'davidhalter/jedi-vim'
Plug 'raimon49/requirements.txt.vim', {'for': 'requirements'}

" solidity
Plug 'tomlion/vim-solidity'
" circom
Plug 'iden3/vim-circom-syntax'

" LaTeX support. It needs latexmk & zathura
Plug 'lervag/vimtex'


" deoplete
Plug 'Shougo/deoplete.nvim'
let g:deoplete#enable_at_startup = 1
autocmd CompleteDone * pclose!
" Plug 'zchee/deoplete-go', {'build': {'unix': 'make'}}
" " neosnippet with deoplete
" Plug 'Shougo/neosnippet.vim'
" Plug 'Shougo/neosnippet-snippets'
" " Plugin deoplete neosnippet key-mappings.
" " Note: It must be "imap" and "smap".  It uses <Plug> mappings.
" imap <C-k>     <Plug>(neosnippet_expand_or_jump)
" smap <C-k>     <Plug>(neosnippet_expand_or_jump)
" xmap <C-k>     <Plug>(neosnippet_expand_target)

" automatically adjust shiftwidth and expand tab based on current file
Plug 'tpope/vim-sleuth'


" errors
Plug 'Valloric/ListToggle'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" after PlugInstall, install coc-rust-analyzer:
" :CocInstall coc-rust-analyzer

" focus mode
Plug 'junegunn/goyo.vim'

" vimwiki
Plug 'vimwiki/vimwiki'
" vim calendar
Plug 'mattn/calendar-vim'

" colors
Plug 'tomasr/molokai'
Plug 'srcery-colors/srcery-vim'
Plug 'rakr/vim-one'
Plug 'morhetz/gruvbox'

call plug#end()

" next 3 lines are needed for vimwiki
set nocompatible
filetype plugin on
syntax on
" vimwiki with markdown
let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
" prevent vimwiki of setting conceallevel=2:
let g:vimwiki_conceallevel=0

let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors

if $COLORTERM == 'gnome-terminal'
  set term=gnome-256color
else
  if $TERM == 'xterm'
    set term=xterm-256color
  endif
endif

set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\


" NERDTree
let NERDTreeShowHidden=1
autocmd vimenter * NERDTree
map <C-n> :NERDTreeToggle<CR>
" NERDCommenter
let g:NERDSpaceDelims = 1 " Add spaces after comment delimiters by default
let g:NERDDefaultAlign = 'left' " Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDCommentEmptyLines = 1 " Allow commenting and inverting empty lines (useful when commenting a region)


"" go config
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction


let g:go_list_type = "quickfix"
let g:go_fmt_command = "goimports"
let g:go_fmt_fail_silently = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_structs = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_space_tab_error = 0
let g:go_highlight_array_whitespace_error = 0
let g:go_highlight_trailing_whitespace_error = 0
let g:go_highlight_extra_types = 1


" vim-airline
"" let g:airline_theme = 'powerlineish'
let g:airline_theme='one'
" let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline_skip_empty_sections = 1


" errors
"" for go needs gopls installed (comes with vim-go pluggin)
"" for rust with rust-analyzer needs https://rust-analyzer.github.io/manual.html#rust-analyzer-language-server-binary installed
""      [old] for rust with rls needs https://github.com/rust-lang/rls installed
let g:lt_location_list_toggle_map = '<leader>l'
let g:lt_quickfix_list_toggle_map = '<leader>s'
" \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
let g:LanguageClient_serverCommands = {
    \ 'go': ['~/go/bin/gopls'],
    \ 'rust': ['rust-analyzer'],
    \ }
let g:LanguageClient_diagnosticsList = "Quickfix"
let g:LanguageClient_diagnosticsEnable = 1

" language server key bindings
nnoremap <F6> :call LanguageClient_contextMenu()<CR>
" Specific mappings of LanguageClient each action separately
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> KK :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

noremap <silent> <C-c>          :cn<CR>

" rainbowparentheses
let g:rainbow_active = 1

"" circom syntax
au BufRead,BufNewFile *.circom set filetype=circom
au BufRead,BufNewFile *.circuit set filetype=go-snark-circuit

"" LaTeX vimtex config:
" Important: This config needs latexmk & zathura to be installed.
" 
" This is necessary for VimTeX to load properly. The "indent" is optional.
" Note that most plugin managers will do this automatically.
filetype plugin indent on
" This enables Vim's and neovim's syntax-related features. Without this, some
" VimTeX features will not work (see ":help vimtex-requirements" for more
" info).
syntax enable
" Viewer options: One may configure the viewer either by specifying a built-in
" viewer method:
let g:vimtex_view_method = 'zathura'

"" sage syntax
augroup filetypedetect
  au! BufRead,BufNewFile *.sage,*.spyx,*.pyx setfiletype python
augroup END

" for file watching
set backupcopy=yes

" copy&paste from system clipboard
vnoremap  <leader>y  "+y
vnoremap  <leader>p  "+p

" shortcut for theme change
nnoremap <F9> :colorscheme gruvbox \| set background=dark \| highlight normal ctermbg=0 guibg=#000000 <CR>
nnoremap <F10> :colorscheme gruvbox \| set background=light<CR>

" colorscheme
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_contrast_light = 'hard'
let g:srcery_italic = 1

set colorcolumn=100
" set textwidth=80

set background=dark 

" colorscheme molokai
colorscheme gruvbox

highlight normal ctermbg=0 guibg=#000000
