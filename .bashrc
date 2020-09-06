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
   # to see the available colours: for COLOR in {1..255}; do echo -en "\e[38;5;${COLOR}m${COLOR} "; done; echo;
 C_USER='99' # 48 for normal green, 99 for server purple
 C_DIR='39'
 C_BRANCH='207'
 PS1='${debian_chroot:+($debian_chroot)}\[\e[01;38;5;'$C_USER'm\]\u@\h\[\033[00m\]:\[\e[01;38;5;'$C_DIR'm\]\w\[\e[38;5;'$C_BRANCH'm\]$(parse_git_branch)\[\033[01;90m\]\[\033[00m\]\$ '
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
alias lst='ls -altr'

# alias
alias n='nvim'
alias t='tmux'
alias c='calcurse-caldav && calcurse && calcurse-caldav'
alias gdf='git difftool --tool=vimdiff'

export PATH=$PATH:/home/user/bin

# go
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go

# rust
export PATH="$HOME/.cargo/bin:$PATH"

# python
alias python='/usr/bin/python3.6'
alias pip='/usr/bin/pip3'

export EDITOR=vim
export LC_ALL="en_US.UTF-8"
