#!/bin/env bash
# @author nate zhou
# @since 2023, 2024
# codeberg.org/unixchad/dotfiles
# github.com/gnuunixchad/dotfiles
# debian post-instal auto-rice script

echo -e '
    _   __      __      _          _____       ____       __    _           
   / | / /___ _/ /____ ( )_____   /  __ \     / __ \___  / /_  (_)___ _____ 
  /  |/ / __ `/ __/ _ \|// ___/  |  /    |   / / / / _ \/ __ \/ / __ `/ __ \
 / /|  / /_/ / /_/  __/ (__  )   |  \___-   / /_/ /  __/ /_/ / / /_/ / / / /
/_/ |_/\__,_/\__/\___/ /____/    -_        /_____/\___/_.___/_/\__,_/_/ /_/
    ___         __             _   --_        _____           _       __ 
   /   | __  __/ /_____  _____(_)_______     / ___/__________(_)___  / /_
  / /| |/ / / / __/ __ \/ ___/ / ___/ _ \    \__ \/ ___/ ___/ / __ \/ __/
 / ___ / /_/ / /_/ /_/ / /  / / /__/  __/   ___/ / /__/ /  / / /_/ / /_  
/_/  |_\__,_/\__/\____/_/  /_/\___/\___/   /____/\___/_/  /_/ .___/\__/  
                                                           /_/
'

last_tested_release="Debian GNU/Linux 12 (bookworm) x86_64"
last_tested_kernel="6.1.0-17-amd64"

echo -e "@author nate zhou\n@since 2023, 2024\n\nlast tested release: $last_tested_release\nlast tested kernel: $last_tested_kernel\n"

local_repo="/var/cache/apt/local-repo"

# ATTENTION: if you have one typo(non-existing package name), the whole line won't be executed by apt-get
# ATTENTION: adding new packages below and to local-repo, without updating dpkg-scanpackages will make whole line of softwares not installed by apt
# `needrestart` will be installed as the last package, in order to make it quieter for this script
repo_base="sudo man dpkg-dev make gcc cryptsetup gnupg curl wget sysstat smartmontools hdparm parted ntfs-3g ssh neovim command-not-found ufw firejail udisks2 rsync git network-manager tmux tree fzf iotop iftop btop ncdu ranger w3m w3m-img zip ncal calc apparmor ntpsec python3"
repo_base_no_rec="smbclient neofetch"

repo_xorg="brightnessctl alsa-utils pulseaudio xorg xinput xterm xsel xwallpaper xdotool xautolock i3 i3lock dunst suckless-tools picom libnotify-bin parcellite lxpolkit"
repo_xorg_no_rec="gnome-themes-extra adwaita-qt flameshot"

repo_extra="rename adb android-file-transfer arandr nvtop figlet cava jp2a openjdk-17-jdk openjdk-17-source fonts-noto-color-emoji fonts-noto-cjk fonts-dejavu-core fonts-dejavu-extra tlp nsxiv cmus zathura mupdf taskwarrior calcurse lunar newsboat transmission-cli ffmpeg ffmpegthumbnailer dict dictd dict-gcide httrack nvtop imagemagick mediainfo id3v2 libimage-exiftool-perl qemu-kvm virt-manager virtinst libvirt-clients bridge-utils libvirt-daemon-system qemu-utils firefox-esr ibus-pinyin ibus-anthy gimp audacity fasttrack-archive-keyring qrencode zbar-tools"

repo_extra_no_rec="geary seahorse redshift mpv lxappearance qt5ct obs-studio kdenlive frei0r-plugins libreoffice libreoffice-gtk3"

# change mirror with `:%s/mirrors.ustc.edu.cn/mirrors.example.com/g`
# mirror here must be identical to the mirror local-repo was downloading packages from
echo "change SourcesList mirror in this file if needed. Default is mirrors.ustc.edu.cn"

# config packages and repos to install
echo  "configing packages and repositories..."
while true; do
    read -p "Do you want to continue ? (y/n): " choice
    if [[ $choice == 'y' || $choice == 'n' ]]; then
        break
    else
        echo "Invalid input."
    fi
done
if [[ $choice != "y" ]]; then
    echo "Bye!"
    exit 0
fi
echo "Continuing..."

# config packages
# install samba server ?
while true; do
    read -p "install samba server ? (y/n): " choice_samba
    if [[ $choice_samba == 'y' || $choice_samba == 'n' ]]; then
        break
    else
        echo "Invalid input."
    fi
done

# install xorg and wm ?
while true; do
    read -p "installing xorg and wm ? (y/n): " choice_x11
    if [[ $choice_x11 == 'y' || $choice_x11 == 'n' ]]; then
        break
    else
        echo "Invalid input."
    fi
done

# install extra packages ?
while true; do
    read -p "installing extra packages? (not if in a VM) (y/n): " choice_extra
    if [[ $choice_extra == 'y' || $choice_extra == 'n' ]]; then
        break
    else
        echo "Invalid input."
    fi
done

# install nvidia-driver ?
while true; do
    read -p "installing nvidia-driver (y/n): " choice_nvdia
    if [[ $choice_nvdia == 'y' || $choice_nvdia == 'n' ]]; then
        break
    else
        echo "Invalid input."
    fi
done

# install from local ?
while true; do
    read -p "Install packages from local repo ? (y/n): " choice_from_local
    if [[ $choice_from_local == 'y' || $choice_from_local == "n" ]]; then
        break
    else
        echo "Invalid input."
    fi
done
if [[ $choice_from_local == 'y' ]]; then
    echo -e "\ntemporarily disconnecting the network is recommended"
    if [ ! -d "/var/cache/apt/local-repo" ]; then
        echo -e "\n/var/cache/apt/local-repo not existing\nmake sure copy the local repos into /var/cache/apt/local-repo/"
        exit 0
    fi
    echo "deb [trusted=yes] file:/var/cache/apt/local-repo ./" > /etc/apt/sources.list.d/local-repo.list
fi

# start making changes to the system
while true; do
    read -p "Strating packages installation. Do you want to continue ? (type exactly yes/no): " choice
    if [[ $choice == 'yes' || $choice == 'no' ]]; then
        break
    else
        echo "Invalid input."
    fi
done
if [[ $choice != "yes" ]]; then
    echo "Bye!"
    exit 0
fi
echo "Continuing..."

# removing packages not used, must be done before downloading/installing any packages, for example geary depends on some of *spell packages, if autopurge is performed after the installation of geary and 1) geary would become unusable, 2) local-repo would be incomplete for installing geary afterwards
echo -e "\nremoving packages not used first..."
apt autopurge -y aspell ispell hspell dictionaries-common wamerican debian-faq doc-debian nano reportbug tasksel manpages-* xdg-user-dirs

echo -e "\nAdding repository mirrors..."
# backup sources.list
cp /etc/apt/sources.list /etc/apt/sources.list~
# comment out existing lines in sources.list
sed -i '/^deb/ s/^/#/' /etc/apt/sources.list

# add mirrors
echo 'deb https://mirrors.ustc.edu.cn/debian bookworm main contrib non-free-firmware non-free' >> /etc/apt/sources.list
echo 'deb https://mirrors.ustc.edu.cn/debian bookworm-updates main contrib non-free-firmware non-free' >> /etc/apt/sources.list
echo 'deb https://mirrors.ustc.edu.cn/debian-security bookworm-security main contrib non-free-firmware non-free' >> /etc/apt/sources.list

# backports for yt-dlp bug fix
echo -e "\nadding backports repo"
sed -i '$a\'"deb https://mirrors.ustc.edu.cn/debian bookworm-backports main" /etc/apt/sources.list
# fasttrack for virtualbox
echo -e "\nadding fasttrack repo"
sed -i '$a\'"deb https://fasttrack.debian.net/debian-fasttrack bookworm-fasttrack main contrib" /etc/apt/sources.list

# codium gitlab
wget https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
mv pub.gpg /usr/share/keyrings/vscodium-archive-keyring.asc
echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.asc ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list

# installing packages
echo -e "\ninstalling base packages"
apt update
apt upgrade --download-only -y
apt upgrade -y

if [[ $choice_from_local == 'n' ]]; then
    while true; do
        read -p "make a local deb repo? (y/n): " choice_make_local
        if [[ $choice_make_local == 'y' ]]; then
            apt --download-only install -y $repo_base
            apt --download-only install -y --no-install-recommends $repo_base_no_rec
            apt --download-only install -y $repo_xorg
            apt --download-only install -y --no-install-recommends $repo_xorg_no_rec
            apt --download-only install -y $repo_extra
            apt --download-only install -y --no-install-recommends $repo_extra_no_rec
            apt --download-only install -y nvidia-driver firmware-misc-nonfree linux-headers-amd64
            apt --download-only install -y -t bookworm-backports yt-dlp
            apt --download-only install -y fasttrack-archive-keyring
            apt install -y fasttrack-archive-keyring
            apt update
            apt install --download-only -y virtualbox
            apt install --download-only -y virtualbox-guest-additions-iso
    
            apt install --download-only -y codium
    
            apt install --download-only -y --no-install-recommends samba
            apt install --download-only -y needrestart
    
            mkdir -p /var/cache/apt/local-repo
            cp -v /var/cache/apt/archives/*.deb /var/cache/apt/local-repo
            apt install -y dpkg-dev
            # scanpackages must be done inside the dir, if the sources.list wanna use `./` as release dist )
            # cd inside parentheses would temporarily change working directory of the running shell
            ( cd /var/cache/apt/local-repo/ ; dpkg-scanpackages -m . | gzip -9c > Packages.gz )
            break
        elif [[ $choice_make_local == 'n' ]]; then
            break
        else
            echo "Invalid input."
        fi
    done
fi

# installing base packages
apt install -y $repo_base
apt install -y --no-install-recommends $repo_base_no_rec

if [[ $choice_samba == 'y' ]]; then
    apt install -y --no-install-recommends samba
    systemctl disable --now nmbd.service
fi

if [[ $choice_x11 == 'y' ]]; then
    apt install -y $repo_xorg
    apt install -y --no-install-recommends $repo_xorg_no_rec
fi

if [[ $choice_extra == 'y' ]]; then
    apt install -y $repo_extra
    apt install -y --no-install-recommends $repo_extra_no_rec
    apt update
    apt install -y virtualbox
    apt install -y virtualbox-guest-additions-iso
    # trying for local-repo, `-t bookworm-backports` will either override with internet, or doing nothing without internet, both ending up with backports version
    apt install -y yt-dlp
    apt install -y -t bookworm-backports yt-dlp
    apt install -y codium
fi

if [[ $choice_nvdia == 'y' ]]; then
    apt install -y nvidia-driver firmware-misc-nonfree linux-headers-amd64
fi

sudo apt install -y needrestart

echo -e "\ndisable bluetooth..."
systemctl disable --now bluetooth.service
# printer server
echo -e "\ndisable cups..."
systemctl disable --now cups.service
# NetworkManager modem plugin, useful for a usb modem
echo -e "\ndisable ModemManager..."
systemctl disable --now ModemManager.service
# automatically mounting removable storage media
echo -e "\ndisable udisks2..."
systemctl disable --now udisks2.service


if [[ $choice_extra == 'y' ]]; then
    echo -e "\nstarting tlp"
    systemctl enable tlp
    tlp start
    cp /etc/tlp.conf /etc/tlp.conf~
    sed -i 's/^#STOP_CHARGE_THRESH_BAT1=80$/STOP_CHARGE_THRESH_BAT1=60/' /etc/tlp.conf
    # manually run `sudo tlp bat` when on battery, below is to fix performance issue with charge threshold with AC
    sed -i 's/^#TLP_DEFAULT_MODE=AC$/TLP_DEFAULT_MODE=AC/' /etc/tlp.conf
    sed -i 's/^#TLP_PERSISTENT_DEFAULT=0$/TLP_PERSISTENT_DEFAULT=1/' /etc/tlp.conf
fi

echo -e "\nchanging kernel.printk log level"
cp /etc/sysctl.conf /etc/sysctl.conf~
sed -i 's/^#kernel.printk = 3 4 1 3$/kernel.printk = 3 4 1 3/' /etc/sysctl.conf

echo -e "\nchanging grub timeout"
cp /etc/default/grub /etc/default/grub~
sed -i 's/^GRUB_TIMEOUT=5$/GRUB_TIMEOUT=1/' /etc/default/grub
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="quiet"$/GRUB_CMDLINE_LINUX_DEFAULT=""/' /etc/default/grub

update-grub

echo -e "\nchanging xkb keycodes"
cp /usr/share/X11/xkb/keycodes/evdev /usr/share/X11/xkb/keycodes/evdev~
sed -i 's/<RWIN> = 134;$/<RWIN> = 108;/' /usr/share/X11/xkb/keycodes/evdev
sed -i 's/<RALT> = 108;$/<RALT> = 134;/' /usr/share/X11/xkb/keycodes/evdev
sed -i 's/<LWIN> = 133;$/<LWIN> = 64;/' /usr/share/X11/xkb/keycodes/evdev
sed -i 's/<LALT> = 64;$/<LALT> = 133;/' /usr/share/X11/xkb/keycodes/evdev

echo -e "\nchanging ssh port"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config~
sed -i 's/^#Port 22$/Port 2910/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication yes$/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh.service
systemctl restart sshd.service

echo -e "\nsetting ufw incoming rules"
ufw allow from 192.168.0.0/16 to any app Samba comment 'LAN samba'
ufw allow from 192.168.0.0/16 to any port 2910 comment 'LAN ssh'
ufw enable

echo -e "\ncreating users and groups..."
useradd -m -s /bin/bash usbnate
useradd -m -s /bin/bash termuxnate
useradd smbnate -s /usr/sbin/nologin
useradd -m -s /bin/bash guest
useradd smbguest -s /usr/sbin/nologin
chmod 750 /home/usbnate /home/termuxnate /home/guest

groupadd dsk
groupadd public
groupadd protected
groupadd private

usermod -aG dsk,public,protected,private,sudo nate
usermod -aG kvm,libvirt nate
usermod -aG dsk,public,protected smbnate
usermod -aG dsk,public termuxnate
usermod -aG dsk usbnate

echo -e "\ncreating basic directories..."
mkdir -m 750 /media/dsk0
mkdir -m 750 /media/dsk1
chown nate:dsk /media/dsk*

sudo -u nate mkdir -m 700 /home/nate/mnt
sudo -u nate ln -s /media/dsk0/back/data/doc doc
sudo -u nate ln -s /media/dsk0/back/data/mus mus
sudo -u nate ln -s /media/dsk0/back/data/pic pic
sudo -u nate ln -s /media/dsk0/back/data/vid vid
sudo -u nate ln -s /media/dsk0/temp temp
sudo -u nate ln -s /media/dsk0/back/repo repo

mkdir -m 1777 /home/public
mkdir -m 775 /home/public/smbshare
chown nate:dsk /home/public
chown nate:dsk /home/public/smbshare

if [[ $choice_samba == 'y' ]]; then
    echo -e "\nsetting up samba..."
    cp /etc/samba/smb.conf /etc/samba/smb.conf~
    echo -e "[smbshare]\n   comment = smbnate's share\n   path = /home/public/smbshare\n   read only = no\n   guest ok = no" >> /etc/samba/smb.conf
    echo -e "[back]\n   comment = smbnate's share\n   path = /media/dsk0/back\n   read only = yes\n   guest ok = no" >> /etc/samba/smb.conf
    echo -e "[live]\n   comment = smbnate's share\n   path = /media/dsk0/live\n   read only = yes\n   guest ok = no" >> /etc/samba/smb.conf
    echo -e "[movies]\n   comment = smbnate's share\n   path = /media/dsk0/movies\n   read only = yes\n   guest ok = no" >> /etc/samba/smb.conf
    echo "entering the samba password for user smbpasswd"
    smbpasswd -a smbnate
    systemctl restart smb.service
    systemctl restart smbd.service
fi

# setup firejail
echo -e "\nsetting up firejail..."
echo -e "root\nnate\nusbnate\ntermuxnate\nguest" > /etc/firejail/firejail.users
cp /etc/firejail/firecfg.config /etc/firejail/firecfg.config~
sed -i 's/^dnsmasq/#dnsmasq/' /etc/firejail/firecfg.config

# start firejail
firecfg

# stop firejail making directories in $HOME for some softwares
cp /etc/firejail/virtualbox.profile /etc/firejail/virtualbox.profile~
sed -i 's/^mkdir ${HOME}\/VirtualBox VMs$/#mkdir ${HOME}\/VirtualBox VMs/' /etc/firejail/virtualbox.profile
cp /etc/firejail/newsboat.profile /etc/firejail/newsboat.profile~
sed -i 's/^mkdir ${HOME}\/.newsboat$/#mkdir ${HOME}\/.newsboat/' /etc/firejail/newsboat.profile
cp /etc/firejail/w3m.profile /etc/firejail/w3m.profile~
sed -i 's/^mkdir ${HOME}\/.w3m/#mkdir ${HOME}\/.w3m/' /etc/firejail/w3m.profile

# copying dotfiles
echo -e "\ncopying dotfiles"
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
rsync -a $script_dir/nate/ /home/nate
# setup a wallpaper
cp -p $script_dir/wallpaper /home/nate/.local/share/wallpaper

echo -e "\nManually source profile needed:\n    . ~/.profile"

if [[ $choice_extra == 'n' ]]; then
    echo -e "\ncleaning sources.list"
    mv /etc/apt/sources.list.d/vscodium.list /etc/apt/sources.list.d/vscodium.list~
else
    # autostart virt network
    echo -e "\nautostarting virsh network"
    virsh net-define /usr/share/libvirt/networks/default.xml
    virsh net-autostart default
    virsh net-start default
    
    echo -e "\nManually load dconf needed after entering X11:\n    dconf load / < ~/.config/dconf-settings"
    echo -e "\nManually copy user.js after starting firefox:\n    cp ~/.config/user.js ~/.mozilla/firefox/*.default-esr/"
    echo -e "\nTLP default to AC for laptops with charging shreshold, when on BAT manually run \"sudo tlp bat\" to save battery life"
fi

if [[ $choice_make_local == 'y' ]]; then
    echo -e "\nlocal-repo craeted in /var/cache/apt/local-repo, cleaning apt/archives cache"
    apt clean
fi

# removing foreign language man files
rm -rf /usr/share/man/??
rm -rf /usr/share/man/??_*

echo -e "\nEnjoy your freedom and happy hacking, bye!"
