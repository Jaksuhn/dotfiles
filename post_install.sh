# vscode extensions
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

# material shell
gnome-extensions enable material-shell@papyelgringo

# firefox setup
echo "Linking userChrome.css & userContent.css to $HOME/.mozilla/firefox/*.default-release/chrome"
ln -sf $HOME/.config/firefox/userChrome.css to $HOME/.mozilla/firefox/*.default-release/chrome
ln -sf $HOME/.config/firefox/userContent.css to $HOME/.mozilla/firefox/*.default-release/chrome
echo "set 'about:config?filter=toolkit.legacyUserProfileCustomizations.stylesheets' to true for the styles to take effect"
echo "and don't forget to load treestyletabs.css"

# https://brakertech.com/self-deleting-bash-script/
currentscript=$0

function finish {
    echo "shredding ${currentscript} and install.py";
    shred -u ${currentscript};
    shred -u install.py;
    shred -u README.md
}

trap finish EXIT