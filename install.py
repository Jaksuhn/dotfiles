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
_PROFILE = "bspwm"

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
    "git",
    "github-cli",
    "grub",
    "micro",
    "mupdf",
    "neofetch",
    "nnn",
    "npm",
    "p7zip",
    "rofi",
    "rust",
    "simplescreenrecorder",
    "telegram-desktop",
    "thefuck",
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
    "zsh-syntax-highlighting",
]

dependencies_aur = [
    "betterlockscreen",
    "code-marketplace",
    "discord_arch_electron",
    "polybar",
    "ttf-ms-fonts",
    "yadm-git",
    "zsh-theme-powerlevel10k-git",
]

bspwm_packages = ["bspwm", "sxhkd", "xdo", "rxvt-unicode", "lightdm-gtk-greeter", "lightdm"]

if archinstall.arguments.get("help", None):
    archinstall.log(" - Optional disk encryption via --!encryption-password=<password>")
    archinstall.log(" - Optional filesystem type via --filesystem=<fs type>")
    archinstall.log(" - Optional systemd network via --network")

archinstall.arguments["harddrive"] = archinstall.select_disk(archinstall.all_disks())
hostname = archinstall.generic_select(["desktop", "laptop"], "Select hostname (default: desktop):") or "desktop"
profile = input(f"Profile (default: bspwm): ") or _PROFILE
root_password = archinstall.get_password("Root password (default: root):") or "root"
user = input(f"Username (default: {DEFAULT_USER}): ") or DEFAULT_USER
user_password = archinstall.get_password(f"Password (default: {user}):") or user

while github_access_token := input("Github Access Token (default: none): "):
    response = requests.post(url="https://api.github.com/", headers={"Authorization": f"token {github_access_token}"})
    if response.status_code == 401 or "admin:public_key" not in response.headers.get("X-OAuth-Scopes"):
        archinstall.log("Token invalid or doesn't have the 'admin:public_key' scope. Try again!", fg="red")
        continue
    break


def install_on(mountpoint):
    with archinstall.Installer(mountpoint) as installation:
        # Strap in the base system, add a boot loader and configure
        # some other minor details as specified by this profile and user.
        mirror_regions = {DOWNLOAD_REGION: archinstall.list_mirrors().get(DOWNLOAD_REGION)}
        archinstall.use_mirrors(mirror_regions)

        installation.minimal_installation()

        installation.set_hostname(hostname)
        installation.set_mirrors(mirror_regions)
        installation.add_bootloader()

        # Optionally enable networking:
        # if archinstall.arguments.get("network", None):
        installation.copy_iso_network_config(enable_services=True)

        installation.arch_chroot(r"sed -i '/\[multilib\]/,/Include/''s/^#//' /etc/pacman.conf")
        installation.arch_chroot(r"sed -i 's/#\(Color\)/\1/' /etc/pacman.conf")

        installation.add_additional_packages(dependencies)

        # bspwm profile not fully tested and config import isn't done
        if profile == "bspwm":
            installation.install_profile("xorg")
            installation.add_additional_packages(bspwm_packages)
            installation.enable_service("lightdm")
            installation.arch_chroot(r"mkdir ~/.config/bspwm")
            installation.arch_chroot(r"mkdir ~/.config/sxhkd")
            installation.arch_chroot(r"install -Dm755 /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/bspwmrc")
            installation.arch_chroot(r"install -Dm644 /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd/sxhkdrc")
            installation.arch_chroot(r"cd .config/sxhkd/")
        else:
            installation.install_profile(profile)

        installation.user_create(str(user), str(user_password))
        installation.arch_chroot(f'chsh -s /usr/bin/zsh "{user}"')

        installation.user_set_pw("root", str(root_password))
        installation.arch_chroot(r"sed -i 's/# \(%wheel ALL=(ALL) ALL\)/\1/' /etc/sudoers")

        installation.enable_service("systemd-timesyncd", "docker", "bluetooth")
        installation.arch_chroot(r"sed -i 's/[#]*\(AutoEnable=\)\(true\|false\)/\1true/' /etc/bluetooth/main.conf")

        autologin_file_name = f"{installation.target}/etc/systemd/system/getty@tty1.service.d/autologin.conf"
        os.makedirs(os.path.dirname(autologin_file_name), exist_ok=True)
        with open(autologin_file_name, "w") as file:
            file.write(f"[Service]\nExecStart=\nExecStart=-/usr/bin/agetty --autologin {user} --noclear %I $TERM")

        installation.arch_chroot(
            f'su {user} -c \'ssh-keygen -t ed25519 -C "{user}@{hostname}" -f ~/.ssh/id_ed25519 -N ""\''
        )
        installation.arch_chroot(f"su {user} -c 'ssh-keyscan github.com >> ~/.ssh/known_hosts'")

        if github_access_token:
            with open(f"{installation.target}/home/{user}/.ssh/id_ed25519.pub", "r") as key:
                requests.post(
                    url="https://api.github.com/user/keys",
                    json={"title": f"{user}@{hostname}", "key": f"{key.read().strip()}"},
                    headers={"Authorization": f"token {github_access_token}"},
                )

        installation.arch_chroot(
            f"su {user} -c 'cd $(mktemp -d) && git clone {'git@github.com:jaksuhn/dotfiles.git' if github_access_token else 'https://github.com/jaksuhn/dotfiles.git'} . && cp -rb . ~'"
        )
        installation.arch_chroot(r"sed -i 's/#\(MAKEFLAGS=\).*/\1\"-j$(($(nproc)-2))\"/' /etc/makepkg.conf")
        installation.arch_chroot(r"sed -i 's/# \(%wheel ALL=(ALL) NOPASSWD: ALL\)/\1/' /etc/sudoers")
        installation.log(
            installation.arch_chroot(
                f"su {user} -c 'cd $(mktemp -d) && git clone https://aur.archlinux.org/paru-bin.git . && makepkg -sim --noconfirm'"
            ),
            level=logging.INFO,
        )
        installation.log(
            installation.arch_chroot(
                f'su {user} -c "paru -Sy --nosudoloop --needed --noconfirm {" ".join(dependencies_aur)}"'
            ),
            level=logging.INFO,
        )
        installation.arch_chroot(r"sed -i 's/\(%wheel ALL=(ALL) NOPASSWD: ALL\)/# \1/' /etc/sudoers")

        installation.arch_chroot(f"chown -R {user}:{user} /home/{user}/paru")
        installation.arch_chroot(r"npm install -g tldr")
        installation.arch_chroot(
            r"sh -c '$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)'"
        )
        installation.arch_chroot(
            r"git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
        )


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