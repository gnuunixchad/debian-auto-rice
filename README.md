@author nate zhou  
@since 2023, 2024  

This script's purpose is to duplicate the Debian GNU/Linux system being used by **me**.

You probably would like to modify the script and some config files' pathname at first.

Configs and scripts are outdated and won't be updated, you can find my newest setup at:  
[codeberg](https://codeberg.org/unixchad/dotfiles)  
[github](https://github.com/gnuunixchad/dotfiles)  

This script was last tested on *Debian 12 x86_64*.

The default wallpaper is created by me and Licensed under Creative Commons.

Steps below are records for personal usage only, it's **NOT A GUIDE** by any means.


![preview1](./2024-01-15_15-15.png)
![preview2](./2023-12-20_09-45-rice.png)

---
# manual installation of a minimal system
## live iso rescure mode
    live mode doesn't have cryptsetup
    
    boot the live iso installer and choose rescure mode
    1. boot to the debian installer (dvd/cd/live all work)
    2. choose `Advanced options` > `rescure mode`
    3. setup language, keyboard, hostname, network can be skiped
    3. if there's LUKS encrypted partition(s), there will be promt(s) for passphrase(s)
    4. if there are LVM logical volumes in a LUKS container, they will also be scaned automatically
    5. choose the /root partition to mount, if it is a LV inside LUKS, it will look like `/dev/lv0/root`, depens on the logical group and logical volume name given at creation.
    6. choose the /boot (for UEFI, and /boot/efi) partition to mount
    7. choose `install grub`

    what's happening in the backgroud should be similar to expert install and change tty to excute following manually:

    ```
    # open the luks container
    cryptsetup luksOpen /dev/nvme0n1p3 nvme0n1p3_crypt
    cryptsetup luksOpen /dev/nvme0n1p4 nvme0n1p4_crypt

    # activate logic volume group (volume group "system" will be mounted at /dev/system)
    lvm vgchange -a y
    # scan logic volumes inside logical volume group
    lvm lvscan
    mount /dev/system/root /mnt
    swapon /dev/system/swap

    # mount non-encrypted efi and /boot partition
    mount /dev/nvme0n1p1 /mnt/boot/efi
    mount /dev/nvme0n1p2 /mnt/boot

    # mount other data partitions
    mount /dev/mapper/nvme0n1p4_crypt /mnt/media/dsk0

    # change root directory
    chroot /mnt
    ```
## secure boot
    for nvidia proprietary driver, disable secure boot

        (Ubuntu signs secure key for the nvidia proprietary driver they packaged
        while on Debian, you have to sign your own key everytime after the nvidia driver update if you want the secure boot turned on.)
## etc
    - don't enable nuc11's fast boot option
    - y700 need disable usb boot after installation, as boot menu isn't passphrase protected unlike UEFI
# preparing local-repo
    disconnect the internet during installation when making local-repo on a new install

    local-repo must download packages with the mirror the same the auto-rice.sh is going to write to the sources.list
    (some packages in base category have issues otherwise)

---
# 1. debian installer
- dark installer and a default dark grub
    1. advanced install options..
    2. text installer with dark theme ...
-  skip network
- don't leave root password empty, it disable's root login in recovery mode
- username must be "nate" to use the auto-rise script
- partition
    - nvme0n1
      - nvme0n1p1 100MB fat32, /boot/efi (EFI)
      - nvme0n1p2 900MB ext2, /boot
      - nvme0n1p3 100GB LUKS 
    	LUKS  encrypted container
        - lv group 100GB system
    	Logical voulme groups inside LUKS container
          - 16ap
          - 84GB root, etc4, /
          	(don't separate /home from /)

    don't modify anything nor mount the rest of partitions/disks

---
# 2. post installation
    login as nate
    `set -o vi`
### tty font size
    `sudo dpkg-reconfigure console-setup` 
        `UTF-8` > 
        `Guess optimal character set`  >
        `Let the system select a suitable font` >
        `14x28`
### (optional/preparing repo in vm)
    enable NIC (reboot not required)
    (`enp1s0` as ethernet interfaces name example)

        sudo cp /etc/network/interfaces /etc/network/interfaces~
        ip a
        sudo sed -i '$a\enp1s0' /etc/network/interfaces
            (or sudo sh -c 'echo enp1s0 >> /etc/network/interface)
            (don't use `echo text | tee file` it is equal to `>`)
    modify to
            auto enp1s0
            iface enp1s0 inet dhcp
            (auto <interface>
             iface <interface> inet dhcp)
        sudo ifup enp1s0
        sudo dhclient enp1s0
### (optional/preparing repo with (hidden) wifi)
    (wlo1 as wireless interface name example)
        sudo sh -c 'wap_passphrase SSID PASSWORD >> /etc/wpa_supplicant/wap_supplicant.conf'
    for hidden SSID, modify to
        network={
                ssid="SSID"
                scan_ssid=1
                #psk="PASSWORD"
                psk=PASSWORD-HASH
        }
    get wireless interface
        ip a
        sudo wpa_supplicant -B -c /etc/wpa_supplicant/wpa_supplicant.conf -i wlo1
            -B background | -c configuration file | -i interface
        sudo dhclient wlo1

    (to let networkmanager take over later
            sudo vim /etc/NetworkManager/NetworkManager.conf
        change `managed=` value to `true`
            sudo systemctl restart NetworkManager.service
### (optional/post-install auto-rice script in vm)
    debian 12 live standard iso doesn't come with ssh-server installed
    in order to get auto-rice script, either
        - temporarily enabled PasswordAuthentication on host and
            (Don't use sudo for auto-rice script)
            scp -P SSH-PORT -r user@ip:/path/to/auto-rice/ ~
            sudo scp -P SSH-PORT -r user@ip:/path/to/local-repo /var/cache/apt/
        - redirect USB in virt-manager
          (if debian installation isn't encrypted, cryptsetup package won't be installed)
            `Virtual Machine` > `Redirect USB Device`
            lsblk
            sudo cryptsetup open /dev/sdX usb_crypt
            sudo mount /dev/mapper/usb_crypt /mnt

### post-install auto-rice script
    (chagge SourcesList mirror in this file if needed. Default is deb.debian.org)
    (change mirror with `:%s/deb.debian.org/mirrors.example.com/g`)
    
    **ATTENTION** auto-rice script must be run with user `nate`, run as root causes terrible permission issues for dotfiles
    
    open any encrypted partition and mount
        sudo cryptsetup open /dev/sdX mapper_name
        sudo mount /dev/mapper/mapper_name /mnt
        cp -r /mnt/back/data/doc/git/auto-rice ~
    
        (**optional** local-repo install)
        cp -r /mnt/back/repo/linux/bookworm/local-repo/ /var/cache/apt/
        (cp -r /mnt/back/repo/linux/bookworm/* /var/cache/apt/)
    
        sudo cp -r ./audo-rice/auto-rice
    
        sudo auto-rice/auto-rice.sh
    
        source ~/.profile
        x (startx)
    (pulseaudio volume control could have permission issue before a reboot)

---
# 3. post auto-rice
    tlp is set to default on ac, to fix performance issue with charging shreshold.
    manually run `sudo tlp bat` when on battery.
## cleaning
    rm -rI ~/auto-rice
    sudo rm -rI /var/cache/apt/local-repo
    sudo mv /etc/apt/sources.list.d/local-repo.list /etc/apt/sources.list.d/local-repo.list~
## dconf
    dconf load / < ~/.config/dconf-settings
    (`dconf reset -f /` to reverse this)
## timezone
    sudo timedatectl set-timezone Region/Country
## hostname
    sudo hostnamectl hostname HOSTNAME
## network
    nmcli device wifi connect <ssid> password <password> hidden yes
    nmcli connection up connection_name
    sudo apt update
## grub resolution
    sudo vim /etc/default/grub`
       GRUB=GFXMOD=1366x768
       (check available resolutions on other systems by:
        1. press `c` in grub menu
        2. `videoinfo`, e.g. y700 1024x768)
    sudo update-grub
## crypttab
### (optional) setup empty disk for /media/dsk0
    (optional) add new partition
        sudo fdisk

    make luks container
        sudo cryptsetup luksFormat /dev/sda4

    unlock luks container
        sudo cryptsetup open /dev/sda4 sda4_crypt

    make filesystem inside container
        sudo mkfs.ext4 /dev/mapper/sda4_crypt
### delete old luks keys used by old install
    sudo cryptsetup luksDump /dev/nvme1n1p1
    sudo cryptsetup luksKillSlot /dev/nvme1n1p1 NUMBER
### create new key
    1. create key
       `sudo su - root`
        add `set -o vi` to /root/.bashrc
       `dd if=/dev/urandom of=/root/crypttab_key bs=1024 count=4`
       `chmod 400 crypttab_key`
        #change back to user nate:
       exit
    2. sudo cryptsetup luksAddKey /dev/nvme1n1p4 /root/crypttab_key`, wait for processing
    3. sudo cp /etc/crypttab /etc/crypttab~
       sudo sh -c 'blkid >> /etc/crypttab'
       sudo vim /etc/crypttab
       delete non-related lines and modify 
            /dev/nvme1n1p4: UUID="xxx-xxx-xxx-xxx-xx" ... 
       into
            nvme1n1p4_crypt UUID=xx-xx-xx-xx /root/crypttab_key luks,discard
       example:
          nvme1n1p3_crypt UUID=xx-xx-xx-xx none luks,discard
          nvme1n1p4_crypt UUID=xx-xx-xx-xx /root/crypttab_key luks,discard
    4. sudo update-initramfs -u -k all
### fstab
    0. unlock all partitions
    	sudo cryptsetup Open /dev/nvme1n1p1 dsk1_crypt
    1. `sudo cp /etc/fstab /etc/fstab~`
    2. `sudo vim /etc/fstab` 
    add line:
        /dev/mapper/nvme0n1p4_crypt /media/dsk0 ext4 defaults 0 2
        /dev/mapper/nvme1n1p1_crypt /media/dsk1 ext4 defaults 0 2
    3. check with `sudo mount -a`, no message means no non-existing UUID or syntax
## ssh
### setup ssh for nate
    `ssh-keygen -t rsa` for ssh (into other systems), keep default name
    `ssh-keygen -t rsa` for git, rename to id_rsa, tell git to use this key for git in .sshconfig
### import pub key
    cp .ssh/id_rsa.pub ~
    smbclient //192.168.xx.xx/smbshare/ -U smbnate
    (smbshare` as `[smbshare]` in host smb.conf)
    put id_rsa.pub
### setup ssh
    cat smbshare/key.txt >> /home/termuxnate/.ssh/authorized_keys
    sudo systemctl restart sshd
## email
    add a easy passphrase to avoid plain text password store
    (it is okay to leave passphrase of seahorse to empty, as the dsk0 is encrypted
    keep in mind this way, the password of the email will be saved in plain text in `~/.local/share/keyrings`)
## cmus theme
    :colorscheme hyper
## codium
### install extensions from file
    gui install can do multiple at once, --install-extension cli only install single file
## virt-manager/qemu/kvm/libvirt
### restore an old vm disk 
    in virt-manager
    	Create a new VM, choosing 
    		import existing disk image of the .qcow2 file, which is the hard drive of the guest OS.
    	add the directory of the image to the libvirt's storage pool first
## vbox add existing .vbox file

## firefox
    (user.js should cover the most of the retarded clicking steps, but not all)
    copy user.js to ~/.mozilla/firefox/**.profle_name/user.js
### creating profiles
    1. about:profile
    2. create a profiles
    3. restore the default-esr as default profile
### common config for all profiles
#### about:config
    layout.css.devPixelsPerPx 0.75
    browser.tabs.closeWindowWithLastTab false
    full-screen-api.ignore-widgets true #video playback fullscreen within window
    browser.fullscreen.autohide false #fullscreen (F11, WM) doesn't hide tab
    extensions.pocket.enabled  false
    network.captive-portal-service.enabled  false
#### about:addons
    1. addons from file, `about:addons`,
    2. uncheck `automatically
    3. install add-on from file
    	darkreader
    	clearurls
    	tridactyl
        i still don't care about cookies
    	ublockO     >enable `filter lists > Regions,languages`
       install only on default profile:
    	dark-theme
    4. copy the block filters to ~/Downloads and import, add AdDuard Chinese filiters under 'Filter lists' > 'Regions, languages'
### about:preferences
    History use custom settings: 
    	uncheck
    		remember browsing and download history
    	clear history when Firefox closes
    		Browsing & download history 
    		Form & search history
    Enhanced Tracking Protection: Strict
    Send websites a "Do Not Track": Always
    Ask to Save logins and passwords: Uncheck
    Firefox Data Collection and Use: Uncheck all
    Firefox to intall and run studies: Uncheck
    HTTPS-Only Mode: Enable in all
    Search Suggestions:
        uncheck: Provide search suggestions
            preventing spying and ads from search bar
    New Windows and Tabs: 
    	homepage and new windows: Custom URLs
    		Use Bookmark, bookmark the newtab of tridactyl
    General
        Downloads: default save to `/media/dsk0/temp`
---
# legacy configs
## ibus IME
    ibus-setup
    General:        next input method       ctrl+space
                    uncheck `Show icon on system tray`
    Input Method:   add > CH-pinyin > JA-Anthy
    Emoji:          annotation:   Ctrl+Shift+e
    Pinyin Preferences:
        Number of candidates: 10
    Anthy Preferences:
        Input Mode: Hiragana
        Key Binding
            Anthy circle_input_mode [] (delete all)
            Anthy circle_kana_mode  []
            Anthy hiragana_mode     [Ctrl+comma]
            Anthy katakana_mode     [Ctrl+period]
    Advanced: uncheck "share the same input method among all applications"
              check `Use custom theme: Awaita-dark`
