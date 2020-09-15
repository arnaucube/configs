# configs
config files

## List of utilities for terminal
- bat https://github.com/sharkdp/bat
- rg https://github.com/BurntSushi/ripgrep
- tig https://github.com/jonas/tig
- gitg
```
alias gitg="git log --color --graph --abbrev-commit --pretty=format:'%Cred%h%Creset%C(yellow)%d%Creset %s %Cgreen(%ar)%C(cyan) %an<%ae>%Creset'"
```
- exa https://github.com/ogham/exa
```
alias ls='exa'
alias lst='exa -l -snew'
```
- fd https://github.com/sharkdp/fd
- jq https://github.com/stedolan/jq
- tmux
- nvim
- mpsyt (mps-youtube) https://github.com/mps-youtube/mps-youtube
- fzf https://github.com/junegunn/fzf


---


- Vim: `.vimrc`
	- put `vimconfigbase.vim` into `~/`
	- put `.vimrc` into `~/`
	- install https://github.com/junegunn/vim-plug
	- inside vim, execute: `:PlugInstall`
- NeoVim: `init.vim`
	- put `vimconfigbase.vim` into `~/`
	- in `.config/nvim/init.vim`
	- install https://github.com/junegunn/vim-plug
	- inside neovim, execute: `:PlugInstall`
	- for the vim-go, execute: :GoInstallBinaries
- `.bashrc`
	- in `~/home/.bashrc` directory
	- execute `source .bashrc`
- Tmux: `.tmux.conf`
	- in `~/home/.tmux.conf` directory
- Keyboard remap `.Xmodmap`
	- in `~/home/.Xmodmap`
	- changes will be applied each session start
	- to apply changes in the current session use `xmodmap ~/.Xmodmap`
- Redshift `redshift.conf`
	- in `~/.config/redshift.conf`
- i3 config files `/i3` and `/i3status` directories go inside `~/.config/` directory


### server side
- radicale `config`
	- in `~/.conf/radicale/config`
