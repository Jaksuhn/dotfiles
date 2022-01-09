###########################################################################################
#   _ __ ___     __ _  | |_    ___   _ __  (_)   __ _  | |    ___  | |__     ___  | | | |
#  | '_ ` _ \   / _` | | __|  / _ \ | '__| | |  / _` | | |   / __| | '_ \   / _ \ | | | |
#  | | | | | | | (_| | | |_  |  __/ | |    | | | (_| | | |   \__ \ | | | | |  __/ | | | |
#  |_| |_| |_|  \__,_|  \__|  \___| |_|    |_|  \__,_| |_|   |___/ |_| |_|  \___| |_| |_|
###########################################################################################
gnome-extensions enable material-shell@papyelgringo
# this is because it may not enable if gnome was recently updated. Version checking is (probably) why
gsettings set org.gnome.shell disable-extension-version-validation "true"