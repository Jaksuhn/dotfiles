# temporary sudo privilges so that password is asked in the beginning and not during
sudo tee /etc/sudoers.d/$USER <<END
$USER ALL=NOPASSWD: /usr/bin/ln, /usr/bin/mkdir, /bin/rm
END

################################################
#  __   __  ___    ___    ___     __| |   ___
#  \ \ / / / __|  / __|  / _ \   / _` |  / _ \
#   \ V /  \__ \ | (__  | (_) | | (_| | |  __/
#    \_/   |___/  \___|  \___/   \__,_|  \___|
################################################
vscode_extensions=(
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

for ext in "${vscode_extensions[@]}"; do
    # ideally find a way to supress the depreciation warnings
    code --install-extension "$ext"
done

###########################################################################################
#   _ __ ___     __ _  | |_    ___   _ __  (_)   __ _  | |    ___  | |__     ___  | | | |
#  | '_ ` _ \   / _` | | __|  / _ \ | '__| | |  / _` | | |   / __| | '_ \   / _ \ | | | |
#  | | | | | | | (_| | | |_  |  __/ | |    | | | (_| | | |   \__ \ | | | | |  __/ | | | |
#  |_| |_| |_|  \__,_|  \__|  \___| |_|    |_|  \__,_| |_|   |___/ |_| |_|  \___| |_| |_|
###########################################################################################
gnome-extensions enable material-shell@papyelgringo
# this may not enable if gnome was recently updated. Version checking is (probably) why
gsettings set org.gnome.shell disable-extension-version-validation "true"

#################################################
#   / _| (_)  _ __    ___   / _|   ___   __  __
#  | |_  | | | '__|  / _ \ | |_   / _ \  \ \/ /
#  |  _| | | | |    |  __/ |  _| | (_) |  >  <
#  |_|   |_| |_|     \___| |_|    \___/  /_/\_\
#################################################
# the .mozilla directory is not created until firefox is launched for the first time
# don't think it's possible to disown firefox --headless so a popup is required
printf "\n\nlaunching firefox to generate .mozilla directory\n"
firefox & disown
sleep 5s
pkill -f firefox
# https://unix.stackexchange.com/questions/374852/create-file-using-wildcard-in-absolute-path
for d in ~/.mozilla/firefox/*.default-release/ ; do
    sudo mkdir "$d"chrome
    sudo mkdir "$d"extensions
    # required for userChrome to work
    echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$d"prefs.js
    # misc preferences
    echo 'user_pref("browser.startup.homepage", "https://www.youtube.com/feed/subscriptions");' >> "$d"prefs.js
    echo 'user_pref("browser.newtabpage.enabled", false);' >> "$d"prefs.js
done
printf "\n\nlinking userChrome.css & userContent.css to $HOME/.mozilla/firefox/*.default-release/chrome\n"
sudo ln -sf $HOME/.config/firefox/userChrome.css to $HOME/.mozilla/firefox/*.default-release/chrome

echo "adding extensions"

# I assume these don't change. This will break if they do. I do not have a way to fetch them automatically.
# The "Addon-icon-image" element on the addon page has the number at the end of the url
# .../xxx-yy.png, where the number is xxx
firefox_extension_ids=(
    607454
    5890
    229918
    2590937
    642100
    735894
    2613823
    387429
    855413
    485620
    812095
    954390
    445852
    14392
)

mkdir tmp_ext_dir && cd tmp_ext_dir
upstream="https://addons.mozilla.org/firefox/downloads/latest"
for ext_id in "${firefox_extension_ids[@]}"; do
    wget -O ext.xpi "${upstream}/${ext_id}/addon-${ext_id}-latest.xpi"
    unzip -p -o ext.xpi manifest.json > manifest.json
    # essentially flattens the json then looks for a key ending with "gecko.id", because the path *to* gecko.id
    # is not the same across extensions
    # https://stackoverflow.com/a/45527527
    # https://stackoverflow.com/questions/53721635/how-can-i-match-fields-with-wildcards-using-jq
    jq 'reduce(tostream | select(length==2) | .[0] |= [join(".")]) as [$p,$v]({}; setpath($p; $v)) | to_entries[] | select(.key|endswith("gecko.id")).value' manifest.json | xargs -I{} rename ext.xpi {}.xpi *
done

shred -u manifest.json
sudo mv -v ~/tmp_ext_dir/* ~/.mozilla/firefox/*.default-release/extensions/
rm -rf ~/tmp_ext_dir

printf "\n\nsign in to firefox\n"
firefox --new-window https://accounts.firefox.com/signin &

#################################
#   _ __ ___   (_)  ___    ___
#  | '_ ` _ \  | | / __|  / __|
#  | | | | | | | | \__ \ | (__
#  |_| |_| |_| |_| |___/  \___|
#################################
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