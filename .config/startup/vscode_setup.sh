################################################
#  __   __  ___    ___    ___     __| |   ___
#  \ \ / / / __|  / __|  / _ \   / _` |  / _ \
#   \ V /  \__ \ | (__  | (_) | | (_| | |  __/
#    \_/   |___/  \___|  \___/   \__,_|  \___|
################################################
vscode_extensions=(
    danielpinto8zz6.c-cpp-compile-run
    davidanson.vscode-markdownlint
    eamodio.gitlens
    formulahendry.code-runner
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
    usernamehw.errorlens
    visualstudioexptteam.vscode
    vscjava.vscode-java-debug
    vscjava.vscode-java-dependency
    vscjava.vscode-java-pack
    vscjava.vscode-java-test
    wwm.better-align
    yzhang.markdown-all-in-one
)

for ext in "${vscode_extensions[@]}"; do
    # ideally find a way to supress the depreciation warnings
    code --install-extension "$ext"
done