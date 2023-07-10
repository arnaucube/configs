# Set up the prompt

autoload -Uz promptinit
promptinit
# prompt adam1
# prompt bart

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
# bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

source ~/.sh_alias

# to see the available colours: for COLOR in {1..255}; do echo -en "\e[38;5;${COLOR}m${COLOR} "; done; echo;

PROMPT='%B%F{48}%n%F{white}:%F{39}%0~%f%b$ '

# git
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_%F{244}%*%f
zstyle ':vcs_info:git:*' formats '%F{207}(%b)%f'
zstyle ':vcs_info:*' enable git

# go
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:~/go/bin
export GOPATH=$HOME/go
alias goimports="~/go/bin/goimports"
alias golint="~/go/bin/golint"
# alias benchcmp="~/go/bin/benchcmp"
# export GOPHERJS_GOROOT="$(go1.12.16 env GOROOT)"

# rust
export PATH="$HOME/.cargo/bin:$PATH"

export EDITOR=vim
export LC_ALL="en_US.UTF-8"

# fzf
[ -f ~/.fzf.zsh ]
if [ -n "${commands[fzf-share]}" ]; then
  source "$(fzf-share)/key-bindings.zsh"
  source "$(fzf-share)/completion.zsh"
fi
