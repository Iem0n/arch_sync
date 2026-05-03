#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

USER_COL="\[\033[38;2;181;189;104;1m\]"
HOST_COL="\[\033[38;2;129;162;190;1m\]"
PATH_COL="\[\033[38;2;150;152;150m\]"
SIGN_COL="\[\033[38;2;130;130;130m\]"
RESET="\[\033[0m\]"

export PS1="${USER_COL}\u${SIGN_COL}@${HOST_COL}\h${RESET}:${PATH_COL}\w${SIGN_COL}\$${RESET} "
. "$HOME/.cargo/env"
