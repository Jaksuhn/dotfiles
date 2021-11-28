import os

import archinstall
import requests
import logging

KEYMAP = "us"
LOCALE = "en_US"
ENCODING = "UTF-8"
TIMEZONE = "US/Eastern"
DOWNLOAD_REGION = "United States"
DEFAULT_USER = "snow"
_PROFILE = "gnome"

dependencies = [
    "bash-completion",
    "baobab",
    "bluez",
    "bluez-utils",
    "code",
    "curl",
    "docker",
    "firefox",
    "firejail",
    "flameshot",
    "git",
    "github-cli",
    "jdk-openjdk",
    "jq",
    "jre-openjdk",
    "kitty",
    "man-db",
    "micro",
    "mupdf",
    "neofetch",
    "nnn",
    "p7zip",
    "qmk",
    "rofi",
    "rust",
    "simplescreenrecorder",
    "sl",
    "telegram-desktop",
    "thefuck",
    "tree",
    "ttf-anonymous-pro",
    "ttf-bitstream-vera",
    "ttf-fira-code",
    "ttf-fira-mono",
    "ttf-fira-sans",
    "ttf-font-awesome",
    "ttf-ibm-plex",
    "ttf-jetbrains-mono",
    "ttf-liberation",
    "ttf-opensans",
    "ttf-roboto",
    "ttf-roboto-mono",
    "vlc",
    "wget",
    "zsh",
]

dependencies_aur = [
    "betterlockscreen",
    "code-marketplace",
    "discord_arch_electron",
    "noto-fonts",
    "noto-fonts-emoji",
    "pokemon-colorscripts-git",
    "polybar",
    "shell-color-scripts",
    "ttf-ms-fonts",
    "yadm-git",
    "zsh-theme-powerlevel10k-git",
]

# TODO: check if that pl10k is redundant

bspwm_packages = ["bspwm", "sxhkd", "xdo", "rxvt-unicode", "lightdm-gtk-greeter", "lightdm"]

# user provided arguments
archinstall.arguments["harddrive"] = archinstall.select_disk(archinstall.all_disks())
hostname = archinstall.generic_select(["desktop", "laptop"], "Select hostname (default: desktop):") or "desktop"
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


def install_on(mountpoint):
    with archinstall.Installer(mountpoint) as i:
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
        i.arch_chroot(
            r"sed -i 's/# Parallel Downloads = [0-9]/Parallel Downloads = 10/g' /etc/pacman.conf"
        )  # parallel downloads

        i.add_additional_packages(dependencies)

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
        else:
            i.install_profile(profile)

        # create user, change login shell
        i.user_create(str(user), str(user_password))
        i.arch_chroot(f'chsh -s /usr/bin/zsh "{user}"')
        i.arch_chroot(f"sed -i '$a{user} ALL=(ALL) NOPASSWD:ALL /etc/sudoers.d/{user}")

        # create root account, grant full sudoers access
        i.user_set_pw("root", str(root_password))
        i.arch_chroot(r"sed -i 's/# \(%wheel ALL=(ALL) ALL\)/\1/' /etc/sudoers")

        # enable systemd services
        i.enable_service("systemd-timesyncd", "docker", "bluetooth", "fstrim.timer")
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
        i.arch_chroot(
            f"su {user} -c 'cd $(mktemp -d) && git clone {'git@github.com:jaksuhn/dotfiles.git' if github_access_token else 'https://github.com/jaksuhn/dotfiles.git'} . && cp -rb . ~'"
        )

        # add more processors to the makepkg build system
        i.arch_chroot(r"sed -i 's/#\(MAKEFLAGS=\).*/\1\"-j$(($(nproc)-2))\"/' /etc/makepkg.conf")
        i.arch_chroot(r"sed -i 's/# \(%wheel ALL=(ALL) NOPASSWD: ALL\)/\1/' /etc/sudoers")  # uncomment

        # install paru and aur packages
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
        i.arch_chroot(r"sed -i 's/\(%wheel ALL=(ALL) NOPASSWD: ALL\)/# \1/' /etc/sudoers")  # comment
        i.arch_chroot(f"chown -R {user}:{user} /home/{user}/paru")


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

install_on("/mnt")
