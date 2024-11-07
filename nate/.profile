# @author nate zhou
# @since 2024

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.

# environment virables should be exported in .profile or .bash_profile
# alias should be in .bashrc

# setting umask for default file permission
# umask     permission
# 022       755 (default user on debian)
# 027       750 (default root on debian)
umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
    PATH="$HOME/.local/bin/dmenu:$PATH"
fi

if [ -d "$HOME/.local/sbin" ] ; then
    PATH="$HOME/.local/sbin:$PATH"
fi

#environments
export TERM=xterm-256color

export LANG=en_US.UTF-8

# locale
export LC_ALL=en_US.UTF-8

# clean up home
# user-specific config files should be (analogous to /etc)
export XDG_CONFIG_HOME="$HOME/.config"
# user-specific non-essential (cached) data should be (analogous to /var/cache)
export XDG_CACHE_HOME="$HOME/.cache"
# user-specific data files should be (analogous to /usr/share)
export XDG_DATA_HOME="$HOME/.local/share"

export CALCHISTFILE="$XDG_CACHE_HOME/calc_history"
export CUDA_CACHE_PATH="$XDG_HOME_HOME/nv"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"

export EDITOR=/bin/nvim;

## ibus
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

# fast jump
export doc="/media/dsk0/back/data/doc/"
export mus="/media/dsk0/back/data/mus/"
export vid="/media/dsk0/back/data/vid/"
export pic="/media/dsk0/back/data/pic/"

export temp="/media/dsk0/temp"
export repo="/media/dsk0/back/repo/"
export movie="/media/dsk0/movie"

export config="$HOME/.config"
export bin="$HOME/.local/bin/"
export sbin="$HOME/.local/sbin/"
export share="$HOME/.local/share/"
export app="$HOME/.local/app/"

export dotfiles="/media/dsk0/back/data/doc/note/dotfiles"
export datafiles="/media/dsk0/back/data/doc/datafiles"
export bookmarks="/media/dsk0/back/data/doc/datafiles/bookmarks/"
export autorice="/media/dsk0/back/data/doc/git/auto-rice"
export records="/media/dsk0/back/data/doc/records"

export smbshare="/home/public/smbshare"

export books="/media/dsk0/back/data/doc/books/"
export code="/media/dsk0/back/data/doc/code/"
export git="/media/dsk0/back/data/doc/git"
export httrack="/media/dsk0/back/data/doc/httrack/"
export note="/media/dsk0/back/data/doc/note/"
export git="/media/dsk0/back/data/doc/git/"
export podcasts="/media/dsk0/back/data/mus/podcasts"
export vocal="/media/dsk0/back/data/mus/vocal"
export instrumental="/media/dsk0/back/data/mus/instrumental"
export gif="/media/dsk0/back/data/pic/gif/"
export wallpapers="/media/dsk0/back/data/pic/wallpapers"

export dsk0="/media/dsk0/"
export dsk1="/media/dsk1/"

# pfetch config
export PF_SOURCE="$HOME/.config/pfetch"

# fix sway no cursor on external monitor
# export WLR_NO_HARDWARE_CURSORS=1
