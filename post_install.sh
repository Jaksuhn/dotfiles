# temporary sudo privilges so that password is asked in the beginning and not during
sudo tee /etc/sudoers.d/$USER <<END
$USER ALL=NOPASSWD: /usr/bin/ln, /usr/bin/mkdir, /bin/rm
END

### vscode extensions
extensions=(
    danielpinto8zz6.c-cpp-compile-run
    formulahendry.code-runner
    github.copilot
    grapecity.gc-excelviewer
    konstantin.wrapselection
    ms-python.python
    ms-vscode.cpptools
    ms-vscode.wordcount
    onlylys.leaper
    qcz.text-power-tools
    redhat.java
    rubymaniac.vscode-paste-and-indent
    sainnhe.gruvbox-material
    tyriar.sort-lines
    visualstudioexptteam.vscode
    vscjava.vscode-java-debug
    vscjava.vscode-java-dependency
    vscjava.vscode-java-pack
    vscjava.vscode-java-test
    wwm.better-align
)

for ext in "${extensions[@]}"; do
    # ideally find a way to supress the depreciation warnings
    code --install-extension "$ext"
done

### material shell
gnome-extensions enable material-shell@papyelgringo
# this may not enable if gnome was recently updated. Version checking is (probably) why
gsettings set org.gnome.shell disable-extension-version-validation "true"

### firefox setup
# the .mozilla directory is not created until firefox is launched for the first time
# don't think it's possible to disown firefox --headless so a popup is required
printf "\n\nlaunching firefox to generate .mozilla directory\n"
firefox & disown
sleep 5s
pkill -f firefox
# https://unix.stackexchange.com/questions/374852/create-file-using-wildcard-in-absolute-path
for d in ~/.mozilla/firefox/*.default-release/ ; do
    sudo mkdir "$d"chrome
    # required for userChrome to work
    echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$d"prefs.js
    echo 'user_pref("browser.startup.homepage", "https://www.youtube.com/feed/subscriptions");' >> "$d"prefs.js
done
printf "\n\nlinking userChrome.css & userContent.css to $HOME/.mozilla/firefox/*.default-release/chrome\n"
sudo ln -sf $HOME/.config/firefox/userChrome.css to $HOME/.mozilla/firefox/*.default-release/chrome

printf "\n\nsign in to firefox\n"
firefox --new-window https://accounts.firefox.com/signin &

# remove temp sudo privileges
sudo /bin/rm /etc/sudoers.d/$USER
sudo -k

# https://brakertech.com/self-deleting-bash-script/
currentscript=$0

function finish {
    shred -u ${currentscript};
    shred -u install.py;
    shred -u README.md
}

trap finish EXIT