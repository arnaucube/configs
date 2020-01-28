#
# [...]
#
# after the default config

# Show git branch name and if there are files not commited show the number
force_color_prompt=yes
color_prompt=yes
parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
check_files_changed() {
  if [ -d .git ]; then
    if ((0!=$(git diff-index HEAD | wc -l))); then
      echo "["$(git diff-index HEAD | wc -l)"]";
    fi;
  fi
}
if [ "$color_prompt" = yes ]; then
 # for username green:
 PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;95m\]$(parse_git_branch)\[\033[01;90m\]$(check_files_changed)\[\033[00m\]\$ '
 # for username pink:
 # PS1='${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;95m\]$(parse_git_branch)\[\033[01;93m\]$(check_files_changed)\[\033[00m\]\$ '
else
 PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)\$ '
fi
unset color_prompt force_color_prompt

# gitg branch views, line from https://gitlab.com/dhole/dot_files/blob/master/.bash_aliases#L39
alias gitg="git log --color --graph --abbrev-commit --pretty=format:'%Cred%h%Creset%C(yellow)%d%Creset %s %Cgreen(%ar)%C(cyan) %an<%ae>%Creset'"

# ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# alias
alias n='nvim'
alias t='tmux'
alias c='calcurse-caldav && calcurse && calcurse-caldav'

# go
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go

# rust
export PATH="$HOME/.cargo/bin:$PATH"

# python
alias python='/usr/bin/python3.6'
alias pip='/usr/bin/pip3'

export EDITOR=vim
