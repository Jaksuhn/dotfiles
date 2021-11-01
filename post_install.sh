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
    code --install-extension "$ext"
done

### material shell
gnome-extensions enable material-shell@papyelgringo

### firefox setup
# the .mozilla directory is not created until firefox is launched for the first time
firefox --headless
pkill -f firefox
# https://unix.stackexchange.com/questions/374852/create-file-using-wildcard-in-absolute-path
for d in /root/.mozilla/firefox/*.default-release/ ; do
    mkdir "$d"/chrome
done
echo "Linking userChrome.css & userContent.css to $HOME/.mozilla/firefox/*.default-release/chrome"
ln -sf $HOME/.config/firefox/userChrome.css to $HOME/.mozilla/firefox/*.default-release/chrome
ln -sf $HOME/.config/firefox/userContent.css to $HOME/.mozilla/firefox/*.default-release/chrome
config_option=toolkit.legacyUserProfileCustomizations.stylesheets
config_value=true
sed -i 's/user_pref("'config_option'",.*);/user_pref("'config_option'",'config_value');/' user.js
grep -q config_option user.js || echo "user_pref(config_option,config_value);" >> user.js
echo "don't forget to load treestyletabs.css"

# https://brakertech.com/self-deleting-bash-script/
currentscript=$0

function finish {
    echo "shredding ${currentscript} and install.py";
    shred -u ${currentscript};
    shred -u install.py;
    shred -u README.md
}

trap finish EXIT