#!/bin/sh
# @author nate zhou
# @since 2024
# this file is the same to /etc/X11/xinit/xinitrc, except calling the preferable 
# window manger at first, this changes the x client (wm) startx is going to call

# put default window manger below, need to be full path, otherwise causes bugs like `i3 exit`
exec /usr/bin/i3

. /etc/X11/Xsession
