# @author nate zhou
# @since 2023

# add interactive (as a login shell, not running script) configs in this file
# environment virables should be exported in .profile or .bash_profile

set -o vi

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put consecutive identical lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# auto cd when entering a path
shopt -s autocd

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=5000
HISTFILESIZE=10000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# git status in prompt
# git-prompt is provided by git package on bookworm
source /etc/bash_completion.d/git-prompt
export GIT_PS1_SHOWDIRTYSTATE=1

# 30 black | 31 red | 32 green | 33 yellow | 34 blue | 35 magenta | 36 cyan | 37 gray|
case $(hostname) in
    "nuc11")
        hostnamecolor=34
    ;;
    *-vm)
        hostnamecolor=33
    ;;
    *)
        hostnamecolor=36
    ;;
esac

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;00m\][\[\033[01;36m\]\u\[\033[00;00m\]@\[\033[01;${hostnamecolor}m\]\h\[\033[00;00m\] \[\033[01;35m\]\W\[\033[01;30m\]\[\033[00m\]]\[\033[00;00m\]$(__git_ps1 "(%s)")\[\033[00m\]\$\[\033[00m\] '


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls -F --color=auto --group-directories-first'
fi

# some more ls aliases
alias ll='ls -lh'
alias la='ls -A'
alias lla='ls -lhA'
alias l.='ls -d .*'     # -d prevents the contents of directories from being listed, not filtering out files that match the pattern.
alias ll.='ls -lh -d .*'

alias ..='cd ..'
alias ...='cd ../..'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# alias
# find out top N most used commands in history
# usage `hs 10` `hs 20` `hs 30`
alias hs="awk 'BEGIN {FS=\"[ \t]+|\\|\"} {print $3}' \"$HISTFILE\" | sort | uniq -c | sort -nr | head -n "

# temporarily disable/enable bash history for current session
alias dishist="set +o history";
alias enhist="set -o history";

alias rm="rm -i";
alias cp="cp -i";
alias mv="mv -i";

alias diff="diff --color=auto";
alias grep="grep --color=auto";

alias whatis="whatis -l";

alias cal="ncal -b";

alias du="du -h";
alias df="df -h -x tmpfs";
alias free="free -h";

alias sp="source $HOME/.profile; echo sourced ~/.profile";
alias xm="xrdb -m $HOME/.Xresources; echo merged ~/.Xresources";

alias gs="git status";
alias gd="git diff";
alias gl="git log --graph --all --abbrev-commit";
alias gf="git log --follow -p";

alias x="startx";

alias transmission-cli="transmission-cli -w /media/dsk0/temp";

alias p="source $HOME/.local/sbin/prox";
alias P="getprox";

# specifies a gcide database to search, excluding mueller7 english-russian database
alias dict='dict -d gcide';

alias less="less -F";

alias poweroff="systemctl poweroff";
alias hibernate="systemctl hibernate";
alias reboot="systemctl reboot";

alias i3lock="i3lock -e -f --color 000000";

alias mupdf="mupdf -I -C cccccc -r 140 -S13";

alias fim="fim -a --no-commandline --no-etc-rc-file --no-stat-push";

alias mpv="mpv --loop";

alias nt="cd $note && git status";
alias tp="cd $temp && ls";
# ranger like directory movement
# starting with `B` to reduce command conflicts
alias Bh="cd $HOME";
alias Bd="cd $doc";
alias Bm="cd $mus";
alias Bp="cd $pic";
alias Bv="cd $vid";

alias Bt="cd $temp";
alias Br="cd $repo";
alias BM="cd $movie";

alias Bc="cd $config";
alias Bb="cd $bin";
alias Bs="cd $share";
alias Ba="cd $app";

alias BS="cd $smbshare";

alias BB="cd $books";
alias BC="cd $code";
alias BH="cd $httrack";
alias BN="cd $note";
alias Bg="cd $git";
alias BR="cd $records";
alias BP="cd $podcasts";
alias BV="cd $vocal";
alias BI="cd $instrumental";
alias BG="cd $gif";
alias BW="cd $wallpapers";

alias BD="cd $dsk0";

alias sync="sync && notify-send -u low -r 3412 'sync finished'";

alias epr="firejail --profile=$HOME/.config/firejail/epr.local epr";
alias epr-zh="firejail --profile=$HOME/.config/firejail/epr-zh.local epr-zh";

alias yt-dlp="yt-dlp --embed-metadata firefox";

# preventing nested ranger instances, form arch wiki
ranger() {
    if [ -z "$RANGER_LEVEL" ]; then
        /usr/bin/ranger "$@"
    else
        exit
    fi
}
