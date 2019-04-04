#
# [...]
#
# after the default config

# Show git branch name
force_color_prompt=yes
color_prompt=yes
parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
if [ "$color_prompt" = yes ]; then
 PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;95m\]$(parse_git_branch)\[\033[00m\]\$ '
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
