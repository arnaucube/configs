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

" 
" " deoplete
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Plug 'zchee/deoplete-go', {'build': {'unix': 'make'}}
" " neosnippet with deoplete
" Plug 'Shougo/neosnippet.vim'
" Plug 'Shougo/neosnippet-snippets'

" automatically adjust shiftwidth and expand tab based on current file
Plug 'tpope/vim-sleuth'

" let g:deoplete#enable_at_startup = 1
" Plugin deoplete neosnippet key-mappings.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)


" errors
Plug 'Valloric/ListToggle'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

" focus mode
Plug 'junegunn/goyo.vim'

" colors
Plug 'tomasr/molokai'
Plug 'srcery-colors/srcery-vim'
Plug 'rakr/vim-one'
Plug 'morhetz/gruvbox'
Plug 'NLKNguyen/papercolor-theme'
let g:srcery_italic = 1

call plug#end()


"Credit joshdick
"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
  "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

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


" go
let g:go_auto_sameids = 1

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
"" for rust needs https://github.com/rust-lang/rls installed
let g:lt_location_list_toggle_map = '<leader>l'
let g:lt_quickfix_list_toggle_map = '<leader>s'
let g:LanguageClient_serverCommands = {
    \ 'go': ['~/go/bin/gopls'],
    \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
    \ }
let g:LanguageClient_diagnosticsList = "Quickfix"
let g:LanguageClient_diagnosticsEnable = 1

" rainbowparentheses
let g:rainbow_active = 1

"" circom syntax
au BufRead,BufNewFile *.circom set filetype=circom
au BufRead,BufNewFile *.circuit set filetype=go-snark-circuit

" for file watching
set backupcopy=yes

" shortcut for theme change
nnoremap <F9> :colorscheme molokai \| set background=dark<CR>
nnoremap <F10> :colorscheme PaperColor \| set background=light<CR>

colorscheme molokai
