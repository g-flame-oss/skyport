#!/bin/bash
#colours
Blue='\033[0;34m'
White='\033[0;37m'
Green='\033[0;32m'
Red='\033[0;31m'
Yellow='\033[0;33m'
#functions
panel() {
    cd /tmp/skyport/
    mkdir /etc/skyport/
    mv /tmp/skyport/assets/panel/* /etc/skyport/
    cd /etc/skyport
    npm install 
    npm run seed
    npm run createUser
    echo -e "${Red}---------------------------------------------${White}"
    echo -e "panel install done!"
}
daemon() {
    cd /tmp/skyport
    mkdir /etc/skyportd
    mv /tmp/skyport/assets/daemon/* /etc/skyportd
    cd /etc/skyportd
    npm install
    echo -e "${Red}---------------------------------------------${White}"
    echo -e "daemon install done!"
}
panel-depends() {
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" |  tee /etc/apt/sources.list.d/nodesource.list
    apt update
    apt install -y nodejs git
}
daemon-depends() {
    curl -sSL https://get.docker.com/ | CHANNEL=stable bash
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main" |  tee /etc/apt/sources.list.d/nodesource.list
    apt update
    apt install -y nodejs git
}
dependencies() {
    panel-depends
    daemon-depends
}
rm-panel() {
    cd /etc/
    rm -rf skyport
}
rm-daemon() {
    cd /etc/
    rm -rf skyportd
}
rm-dependencies() {
if command -v docker &> /dev/null; then
    apt-get remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    rm -f /etc/apt/sources.list.d/docker.list
fi
if command -v node &> /dev/null; then
    apt-get remove -y nodejs git
    rm -f /etc/apt/sources.list.d/nodesource.list
fi
rm -f /etc/apt/keyrings/docker.gpg
rm -f /etc/apt/keyrings/nodesource.gpg
apt-get autoremove -y
apt-get autoclean
apt-get update
echo "Uninstallation of Docker and Node.js is complete."
}
##ui
greet() {
echo -e " ${Blue}----${Green}INSTALLER HOME${Yellow}--------${White}"
echo -e " ${Blue}           __                          __  ${White}"
echo -e " ${Blue}     _____/ /____  ______  ____  _____/ /_ ${White}"
echo -e " ${Blue}   / ___/ //_/ / / / __ \/ __ \/ ___/ __/  ${White}"
echo -e " ${Blue}   (__  ) ,< / /_/ / /_/ / /_/ / /  / /_   ${White}"
echo -e " ${Blue}  /____/_/|_|\__, / .___/\____/_/   \__/   ${White}"
echo -e " ${Blue}           /____/_/                        ${White}"
echo -e " ${Blue}skyport${White} asm software installer!"
echo -e " panel and daemon by ${Blue}skyportlabs${White} © (depreceate${White})"
echo -e " install script by ${Green}Greenflame1507!${White}" 
}
root() {
    if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run with root account or use sudo to start the script!${NC}"
    exit 1
fi 
}
ui() {
    root
    greet
    echo -e "1)${Green}install ${Blue}panel and daemon${White}(dependencies too)!"
    echo -e "2)${Green}install ${Blue}panel${White} only!"
    echo -e "3)${Green}install ${Blue}daemon${White} only!"
    echo -e "4)${Green}install ${Blue}dependencies${White} (both panel and daemon depends!)only!"
    echo -e "5)${Red}remove ${Blue}panel and daemon!${White}!"
    echo -e "6)${Red}remove ${Blue}panel${White} only!"
    echo -e "7)${Red}remove ${Blue}daemon${White} only!"
    echo -e "8)${Red}remove ${Blue}dependencies${White} only !"
    echo -e "9)${Red}exit${White} installer!"
    read -p "what do you want to do ? [1-9]: " choice
    #choice outputs
    case $choice in
    1)
        dependencies
        panel
        daemon
        echo -e "${Yellow}-_--_--_--_--_--_-${Green}Log End${Yellow}-_--_--_--_--_--_--_--_--_-${White}"
        ui
        echo "completed!"
        ;;
    2)
        panel-depends
        panel 
        echo -e "${Yellow}-_--_--_--_--_--_-${Green}Log End${Yellow}-_--_--_--_--_--_--_--_--_-${White}"
        ui
        echo "completed!"
        ;;
    3)
        daemon-depends
        daemon
        echo -e "${Yellow}-_--_--_--_--_--_-${Green}Log End${Yellow}-_--_--_--_--_--_--_--_--_-${White}"
        ui
        echo "completed!"
        ;;
    4)
        dependencies
        echo -e "${Yellow}-_--_--_--_--_--_-${Green}Log End${Yellow}-_--_--_--_--_--_--_--_--_-${White}"
        ui
        echo "completed!"
        ;;
    5)
        rm-panel
        rm-daemon
        echo -e "${Yellow}-_--_--_--_--_--_-${Green}Log End${Yellow}-_--_--_--_--_--_--_--_--_-${White}"
        ui
        echo "completed!"
        ;;
    6)
        rm-panel
        echo -e "${Yellow}-_--_--_--_--_--_-${Green}Log End${Yellow}-_--_--_--_--_--_--_--_--_-${White}"
        ui
        echo "completed!"
        ;;
    7)
        rm-daemon
        echo -e "${Yellow}-_--_--_--_--_--_-${Green}Log End${Yellow}-_--_--_--_--_--_--_--_--_-${White}"
        ui
        echo "completed!"
        ;;
    8)
        rm-dependencies
        echo -e "${Yellow}-_--_--_--_--_--_-${Green}Log End${Yellow}-_--_--_--_--_--_--_--_--_-${White}"
        ui
        echo "completed!"
        ;;
    9)
        echo "remove the installer?"
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) rm installer.sh; break;;
                No ) exit;;
            esac
        done
        echo "bye !"
        exit
        ;;
   *)
        echo -e "\n${RED}thats not an option !${White}"
        ui
        ;;
    esac

    echo -e "\nPress Enter to continue..."
    read
}
##EXECUTING 
clear
ui
## i know my code is shit don't run salt in a wound 
