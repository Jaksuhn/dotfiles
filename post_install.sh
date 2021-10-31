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

gnome-extensions enable material-shell@papyelgringo

# https://brakertech.com/self-deleting-bash-script/
currentscript=$0

function finish {
    echo "shredding ${currentscript} and install.py";
    shred -u ${currentscript};
    shred -u install.py;
    shred -u README.md
}

trap finish EXIT