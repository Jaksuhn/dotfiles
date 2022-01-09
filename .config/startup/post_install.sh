#################################
#   _ __ ___   (_)  ___    ___
#  | '_ ` _ \  | | / __|  / __|
#  | | | | | | | | \__ \ | (__
#  |_| |_| |_| |_| |___/  \___|
#################################

# remove temp sudo privileges and auto startup
# sudo sed -i "/$USER ALL=(ALL) NOPASSWD:ALL/d" /etc/sudoers.d/$USER
sed -i '/# everything after this line will be removed automatically/,$d' ~/.zshrc
