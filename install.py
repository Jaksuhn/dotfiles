import os
from inspect import cleandoc

import archinstall
import requests
import logging
import re

KEYMAP = "us"
LOCALE = "en_US"
ENCODING = "UTF-8"
TIMEZONE = "US/Eastern"
DOWNLOAD_REGION = "United States"
DEFAULT_USER = "snow"
_PROFILE = "xfce4"

BRANCH = "testing"

dependencies = [
    "bash-completion",
    "baobab",
    "bluez",
    "bluez-utils",
    "code",
    "curl",
    "firefox",
    "firejail",
    "flameshot",
    "git",
    "github-cli",
    "iwd",
    "jdk-openjdk",
    "jq",
    "jre-openjdk",
    "kitty",
    "man-db",
    "micro",
    "mupdf",
    "neofetch",
    "networkmanager",
    "network-manager-applet",
    "nnn",
    "noto-fonts-cjk",
    "noto-fonts-emoji",
    "ntfs-3g",
    "pulseaudio",
    "qmk",
    "rust",
    "simplescreenrecorder",
    "sl",
    "syncthing",
    "telegram-desktop",
    "thefuck",
    "tree",
    "ttc-iosevka",
    "ttc-iosevka-curly-slab",
    "ttf-font-awesome",
    "ttf-ibm-plex",
    "ttf-liberation",
    "ttf-opensans",
    "ttf-roboto",
    "unzip",
    "vlc",
    "wget",
    "zsh",
]

dependencies_aur = [
    "7-zip",
    "code-marketplace",
    "discord_arch_electron",
    "nerd-fonts-anonymous-pro",
    "nerd-fonts-fira-code",
    "nerd-fonts-jetbrains-mono",
    "nerd-fonts-noto",
    "nerd-fonts-roboto-mono",
    "onlyoffice-bin",
    "pokemon-colorscripts-git",
    "shell-color-scripts",
    "yadm-git",
    "zsh-theme-powerlevel10k-git",
]

# TODO: check if that pl10k is redundant

bspwm_packages = ["bspwm", "sxhkd", "xdo", "rxvt-unicode", "lightdm-gtk-greeter", "lightdm", "polybar"]
awesome_packages = [
    "playerctl",
    "acpi",
    "pamixer",
    "brightnessctl",
    "lightdm-gtk-greeter",
    "lightdm",
    "upower",
    "rofi",
    "xorg-xinput",
    "picom",
    "feh",
    "xfce4",
    "gvfs",
]
xfce4_packages = ["gtk-engine-murrine", "gtk-engines", "lightdm-webkit2-greeter", "gvfs"]

# user provided arguments
archinstall.arguments["harddrive"] = archinstall.select_disk(archinstall.all_disks())
hostname = input(f"Select hostname (default: desktop):") or "desktop"
profile = input(f"Profile (default: {_PROFILE}): ") or _PROFILE
root_password = archinstall.get_password("Root password (default: root):") or "root"
user = input(f"Username (default: {DEFAULT_USER}): ") or DEFAULT_USER
user_password = archinstall.get_password(f"Password (default: {user}):") or user

# the git sections are entirely from phisch
# https://github.com/phisch/dotfiles
while github_access_token := input("Github Access Token (default: none): "):
    response = requests.post(url="https://api.github.com/", headers={"Authorization": f"token {github_access_token}"})
    if response.status_code == 401 or "admin:public_key" not in response.headers.get("X-OAuth-Scopes"):
        archinstall.log("Token invalid or doesn't have the 'admin:public_key' scope. Try again!", fg="red")
        continue
    break


def write_hosts(i):
    data = """\
        127.0.0.1   localhost
        ::1         localhost ip6-localhost ip6-loopback
        ff00::0     ip6-localnet
        ff00::0     ip6-mcastprefix
        ff02::1     ip6-allnodes
        ff02::2     ip6-allrouters
        ff02::3     ip6-allhosts\
    """
    with open("/etc/hosts", "w") as w:
        w.write(cleandoc(data))


if archinstall.arguments["harddrive"]:
    archinstall.arguments["harddrive"].keep_partitions = False

    print(f" ! Formatting {archinstall.arguments['harddrive']} in ", end="")
    archinstall.do_countdown()

    # First, we configure the basic filesystem layout
    with archinstall.Filesystem(archinstall.arguments["harddrive"], archinstall.GPT) as fs:
        # We use the entire disk instead of setting up partitions on your own
        if archinstall.arguments["harddrive"].keep_partitions is False:
            fs.use_entire_disk(root_filesystem_type=archinstall.arguments.get("filesystem", "btrfs"))

        boot = fs.find_partition("/boot")
        root = fs.find_partition("/")

        boot.format("vfat")

        # We encrypt the root partition if we got a password to do so with,
        # Otherwise we just skip straight to formatting and installation
        if archinstall.arguments.get("!encryption-password", None):
            root.encrypted = True
            root.encrypt(password=archinstall.arguments.get("!encryption-password", None))

            with archinstall.luks2(
                root, "luksloop", archinstall.arguments.get("!encryption-password", None)
            ) as unlocked_root:
                unlocked_root.format(root.filesystem)
                unlocked_root.mount("/mnt")
        else:
            root.format(root.filesystem)
            root.mount("/mnt")

        boot.mount("/mnt/boot")

with archinstall.Installer("/mnt") as i:
    # Strap in the base system, add a boot loader and configure
    # some other minor details as specified by this profile and user.
    mirror_regions = {DOWNLOAD_REGION: archinstall.list_mirrors().get(DOWNLOAD_REGION)}
    archinstall.use_mirrors(mirror_regions)

    i.minimal_installation()

    i.set_hostname(hostname)
    i.set_mirrors(mirror_regions)
    i.add_bootloader()

    # enable networking
    i.copy_iso_network_config(enable_services=True)

    i.arch_chroot(r"sed -i '/\[multilib\]/,/Include/''s/^#//' /etc/pacman.conf")  # enable 32-bit apps
    i.arch_chroot(r"sed -i 's/#\(Color\)/\1/' /etc/pacman.conf")  # enable coloured output
    i.arch_chroot(r"sed -i '/VerbosePkgLists/s/^#//' /etc/pacman.conf")  # enable detailed output
    i.arch_chroot(
        r"sed -i 's/# Parallel Downloads = [0-9]/Parallel Downloads = 10/g' /etc/pacman.conf"
    )  # parallel downloads

    # fix potential gpg key issues when using an older ISO
    i.log(i.arch_chroot("pacman -Sy && pacman -S archlinux-keyring --noconfirm"), level=logging.INFO)
    i.log(i.add_additional_packages(dependencies), level=logging.INFO)

    # create root account, grant root access
    i.user_set_pw("root", str(root_password))
    i.arch_chroot(r"sed -i 's/# \(%wheel ALL=(ALL) ALL\)/\1/' /etc/sudoers")

    # create user, change login shell
    i.user_create(str(user), str(user_password))
    i.log(i.arch_chroot(f'chsh -s /usr/bin/zsh "{user}"'), level=logging.INFO)
    i.log(i.arch_chroot(f"sed -i '/root ALL=(ALL:ALL) ALL/a{user} ALL=(ALL:ALL) ALL' /etc/sudoers"))

    # the profiles are tricky to customise from chroot. May remove and place in a post-install .sh file
    if profile == "bspwm":
        i.install_profile("xorg")
        i.add_additional_packages(bspwm_packages)
        i.enable_service("lightdm")
        i.arch_chroot(
            f"su {user} -c 'mkdir ~/temp_configs && cd ~/temp_configs && git clone https://github.com/joni22u/dotfiles . && cp -rb . ~/.config && rm -rf ~/temp_configs'"
        )
    elif profile == "kde":
        i.install_profile(profile)
        i.arch_chroot("lookandfeeltool -a GruvboxPlasma")
    elif profile == "gnome":
        i.install_profile(profile)
        dependencies_aur.append("gnome-shell-extension-material-shell")
        # remove 'bloat'
        # i.log(
        #     i.arch_chroot(
        #         "pacman -Rns gnome-software gnome-weather gnome-contacts gnome-calendar gnome-boxes epiphany gnome-books gedit gnome-music simple-scan gnome-maps gnome-photos totem gnome-clocks gnome-calculator eog sushi evince file-roller gnome-screenshot gnome-characters gnome-backgrounds"
        #     )
        # )
    elif profile == "awesome":
        # https://github.com/JavaCafe01/dotfiles/ (mostly)
        # https://gitlab.com/ihciM/dotfiles
        i.install_profile("xorg")
        i.add_additional_packages(awesome_packages)
        dependencies_aur.append("awesome-git")
        i.enable_service("lightdm")
        # set awesome to run over xfce
        i.arch_chroot("xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command -t string -sa xfsettingsd")
        i.arch_chroot("xfconf-query -c xfce4-session -p /sessions/Failsafe/Client1_Command -t string -sa awesome")
        i.arch_chroot('xfconf-query -c xsettings -p /Gtk/FontName -s "Roboto 10"')
        i.arch_chroot('xfconf-query -c xsettings -p /Gtk/MonospaceFontName -s "JetBrainsMono Nerd Font 10"')
        # look into https://github.com/vlfldr/rofi-wifi-menu or https://github.com/ericmurphyxyz/rofi-wifi-menu
    elif profile == "xfce4":
        i.install_profile(profile)
        i.add_additional_packages(xfce4_packages)
        dependencies_aur.append("lightdm-webkit2-theme-glorious")
        i.log(
            i.arch_chroot(
                f"su {user} -c 'cd $(mktemp -d) && git clone https://github.com/vinceliuice/Qogir-theme . && $SHELL install.sh'"
            ),
            level=logging.INFO,
        )
        i.log(
            i.arch_chroot(
                f"su {user} -c 'cd $(mktemp -d) && git clone https://github.com/vinceliuice/Qogir-icon-theme . && $SHELL install.sh && cd src/cursors && $SHELL install.sh'"
            ),
            level=logging.INFO,
        )
        # Set default lightdm greeter to lightdm-webkit2-greeter
        # Cannot get sed -i 's/^#\(greeter-session=\).*/\1lightdm-webkit2-greeter/'
        # to work. I'll change this if I find a fix.
        try:
            with open("/etc/lightdm/lightdm.conf") as r:
                data = re.sub(r"(^#greeter-session=.*)", "greeter-session=lightdm-webkit2-greeter", r.read())
            with open("/etc/lightdm/lightdm.conf", "w") as w:
                w.write(data)
        except:
            pass
        # Set default lightdm-webkit2-greeter theme to Glorious
        i.log(
            i.arch_chroot(
                "sed -i 's/^webkit_theme\s*=\s*\(.*\)/webkit_theme = glorious #\1/g' /etc/lightdm/lightdm-webkit2-greeter.conf"
            ),
            level=logging.INFO,
        )
        i.log(
            i.arch_chroot(
                "sed -i 's/^debug_mode\s*=\s*\(.*\)/debug_mode = true #\1/g' /etc/lightdm/lightdm-webkit2-greeter.conf"
            ),
            level=logging.INFO,
        )
    else:
        i.install_profile(profile)

    # enable systemd services
    i.log(
        i.enable_service("iwd", "NetworkManager", "systemd-timesyncd", "bluetooth", "fstrim.timer"),
        level=logging.INFO,
    )
    i.arch_chroot(r"sed -i 's/[#]*\(AutoEnable=\)\(true\|false\)/\1true/' /etc/bluetooth/main.conf")

    i.arch_chroot(f'su {user} -c \'ssh-keygen -t ed25519 -C "{user}@{hostname}" -f ~/.ssh/id_ed25519 -N ""\'')
    i.arch_chroot(f"su {user} -c 'ssh-keyscan github.com >> ~/.ssh/known_hosts'")

    if github_access_token:
        with open(f"{i.target}/home/{user}/.ssh/id_ed25519.pub", "r") as key:
            requests.post(
                url="https://api.github.com/user/keys",
                json={"title": f"{user}@{hostname}", "key": f"{key.read().strip()}"},
                headers={"Authorization": f"token {github_access_token}"},
            )

    # clone dotfiles
    i.log(
        i.arch_chroot(
            f"su {user} -c 'cd $(mktemp -d) && git clone -b {BRANCH} {'git@github.com:jaksuhn/dotfiles.git' if github_access_token else 'https://github.com/jaksuhn/dotfiles.git'} . && cp -rb . ~'"
        ),
        level=logging.INFO,
    )
    i.log(i.arch_chroot(f"su {user} -c 'rm -rf ~/.git'"), level=logging.INFO)
    i.log(i.arch_chroot(f"su {user} -c 'chmod +x ~/.config/startup/touchpad.sh'"), level=logging.INFO)

    # add more processors to the makepkg build system
    i.arch_chroot(r"sed -i 's/#\(MAKEFLAGS=\).*/\1\"-j$(($(nproc)-2))\"/' /etc/makepkg.conf")

    # install paru and aur packages
    i.arch_chroot(r"sed -i 's/# \(%wheel ALL=(ALL:ALL) NOPASSWD: ALL\)/\1/' /etc/sudoers")
    i.log(
        i.arch_chroot(
            f"su {user} -c 'cd $(mktemp -d) && git clone https://aur.archlinux.org/paru-bin.git . && makepkg -sim --noconfirm'"
        ),
        level=logging.INFO,
    )
    i.log(
        i.arch_chroot(f'su {user} -c "paru -Sy --nosudoloop --needed --noconfirm {" ".join(dependencies_aur)}"'),
        level=logging.INFO,
    )
    # i.arch_chroot(r"sed -i 's/\(%wheel ALL=(ALL:ALL) NOPASSWD: ALL\)/# \1/' /etc/sudoers")
    i.log(i.arch_chroot(f"chown -R {user}:{user} /home/{user}/paru"), level=logging.INFO)

    # setup yadm
    i.log(
        i.arch_chroot(f"su {user} -c 'yadm clone --branch {BRANCH} https://github.com/jaksuhn/dotfiles'"),
        level=logging.INFO,
    )
    i.arch_chroot(f"su {user} -c 'git config --global user.name \"{user}\"'")
    i.arch_chroot(f"su {user} -c 'git config --global user.email \"{user}@{hostname}\"'")

    # write hosts file. For some reason, (recently) this is needed for firefox
    write_hosts(i)

    # add screenshot folder for flameshot
    i.arch_chroot("mkdir -p ~/Screenshots")

    # fetch nnn plugins
    i.log(
        i.arch_chroot(
            f"su {user} -c 'curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh'"
        ),
        level=logging.INFO,
    )

    # adding material icons
    i.log("\ninstalling material icons")
    i.log(i.arch_chroot("mkdir -p /usr/local/share/fonts/"))
    i.log(
        i.arch_chroot(
            "wget -O /usr/local/share/fonts/material-design-icons.ttf https://github.com/Templarian/MaterialDesign-Font/raw/master/MaterialDesignIconsDesktop.ttf"
        )
    )

    # install cht.sh
    i.log("\ninstalling cht.sh")
    r = requests.get("https://cht.sh/:cht.sh")
    with open(f"{i.target}/usr/local/bin/cht.sh", "wb") as cht:
        cht.write(r.content)
    i.log(i.arch_chroot(f"setfacl -m u:{user}:rx /usr/local/bin/cht.sh"), level=logging.INFO)
    i.log(i.arch_chroot(f"su {user} -c 'curl https://cheat.sh/:zsh > ~/.config/zsh/_cht'"), level=logging.INFO)

    if input("Go into shell (y/n)?") == "y":
        try:
            i.drop_to_shell()
        except:
            pass
