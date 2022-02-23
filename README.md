# dotfiles


These are my dotfiles, built with the express purpose of being able to go from a blank machine to *exactly* how I've had it with little-to-no user intervention required. I mess around with other window managers, so the installer will ask what profile to use. Other profiles are a very WIP feature atm (in terms of getting them setup to how I've had them). Some sort of work, some add nothing.

## setup

1. get the latest [arch ISO](https://archlinux.org/download/)
2. boot it up and run `python <(curl -sL https://raw.github.com/jaksuhn/dotfiles/main/install.py)`
3. open kitty when you log in; run the `setup-<app>` alias(es)
4. enable all firefox addons (`about:addons`)
5. import the various extension configs (uBlock, TST, SkipRedirect, Imagus)


## package list:

### terminal

[7-zip](https://www.7-zip.org/);
[bash-completion](https://github.com/scop/bash-completion);
[cheat.sh](https://cheat.sh/) (manual aggregator);
[git](https://git-scm.com/);
[github-cli](https://github.com/cli/cli);
[jq](https://stedolan.github.io/jq/) (CLI JSON parser);
[kitty](https://github.com/kovidgoyal/kitty) (terminal emulator);
[man-db](https://www.nongnu.org/man-db/);
[micro](https://micro-editor.github.io/) (txt editor);
[nnn](https://github.com/jarun/nnn) (cli file manager);
[thefuck](https://github.com/nvbn/thefuck) (fuck);
[tree](http://mama.indstate.edu/users/ice/tree/) (directory tree);
[wget](https://www.gnu.org/software/wget/wget.html);
[zsh](https://www.zsh.org/);
[zsh-theme-powerlevel10k-git](https://github.com/romkatv/powerlevel10k)

### stupid terminal shit

[neofetch](https://github.com/dylanaraps/neofetch) (system info);
[pokemon-colorscripts-git](https://gitlab.com/phoneybadger/pokemon-colorscripts);
[shell-color-scripts](https://gitlab.com/dwt1/shell-color-scripts);
[sl](http://www.tkl.iis.u-tokyo.ac.jp/~toyoda/index_e.html) (when you misspell *ls*)

### utilities

[baobab](https://wiki.gnome.org/Apps/DiskUsageAnalyzer) (disk usage);
[bluez & bluez-utils](https://github.com/bluez/bluez) (bluetooth);
[curl](https://curl.se/);
[firejail](https://github.com/netblue30/firejail) (sandboxing);
[flameshot](https://github.com/flameshot-org/flameshot) (screenshots);
[iwd](https://git.kernel.org/cgit/network/wireless/iwd.git/);
[qmk](https://github.com/qmk/qmk_cli) (mechanical keyboard configurator);
[simplescreenrecorder](https://www.maartenbaert.be/simplescreenrecorder/);
[syncthing](https://syncthing.net/);
[unzip](http://infozip.sourceforge.net/UnZip.html);
[yadm-git](https://github.com/TheLocehiliosan/yadm) (dotfile manager)

### applications

[code](https://github.com/microsoft/vscode);
[discord_arch_electron](https://discordapp.com/);
[docker](https://www.docker.com/);
[firefox](https://www.mozilla.org/firefox/);
[mupdf](https://mupdf.com/);
[onlyoffice](https://www.onlyoffice.com/);
[telegram-desktop](https://desktop.telegram.org/);
[vlc](https://www.videolan.org/vlc/)

### languages

[jdk-openjdk](https://openjdk.java.net/);
[jre-openjdk](https://openjdk.java.net/);
[rust](https://www.rust-lang.org/);

### misc.

[code-marketplace](https://marketplace.visualstudio.com/vscode)

### fonts

[material-design-icons](https://github.com/Templarian/MaterialDesign-Font/);
[nerd-fonts-anonymous-pro](https://github.com/ryanoasis/nerd-fonts);
[nerd-fonts-fira-code](https://github.com/ryanoasis/nerd-fonts);
[nerd-fonts-jetbrains-mono](https://github.com/ryanoasis/nerd-fonts);
[nerd-fonts-noto](https://github.com/ryanoasis/nerd-fonts);
[nerd-fonts-roboto-mono](https://github.com/ryanoasis/nerd-fonts);
[noto-fonts-cjk](https://www.google.com/get/noto/);
[noto-fonts-emoji](https://www.google.com/get/noto/);
[ttc-iosevka](https://typeof.net/Iosevka/);
[ttc-iosevka-curly-slab](https://typeof.net/Iosevka/);
[ttf-fira-mono](https://github.com/mozilla/Fira);
[ttf-fira-sans](https://github.com/mozilla/Fira);
[ttf-font-awesome](https://fontawesome.com/);
[ttf-ibm-plex](https://github.com/IBM/plex);
[ttf-liberation](https://github.com/liberationfonts/liberation-fonts);
[ttf-ms-fonts](http://corefonts.sourceforge.net/);
[ttf-opensans](https://fonts.google.com/specimen/Open+Sans);
[ttf-roboto](https://material.google.com/style/typography.html);


## WORKING:

- Profiles: GNOME, Awesome
- Applications: kitty, zsh, vscode, firefox
- yadm

## TODO:

config:

- latex environment
- neofetch
- git
- lockscreen

profiles to port:

- kde
- bspwm
- i3
- sway

misc:

- make gnome (awesome too) show hidden files by default
- sign into firefox via terminal
- auto discord/telegram signin?
- add telegram's theme
- make neofetch rotate through ascii/images
- [dual github accounts setup](https://stackoverflow.com/questions/62625513/can-i-log-in-two-different-github-account-in-vscode)
- setup [ptSh](https://github.com/jszczerbinsky/ptSh)
- setup [rofimoji](https://github.com/fdw/rofimoji) or something similar for material/FA icons
