#!/bin/sh
# colours
Blue='\033[0;34m'
White='\033[0;37m'
Green='\033[0;32m'
Red='\033[0;31m'
Yellow='\033[0;33m'
NC='\033[0m' # No Color

cd /app/data/

# Install necessary packages
apk add --no-cache dos2unix wget zip unzip apache2

ui() {
    echo -e "${Blue}[1]${NC} Start server"
    echo -e "${Blue}[2]${NC} Update server"
    echo -e "${Blue}[3]${NC} Download backup zip"
    echo -e "${Blue}[4]${NC} Use cli"
    echo -e "${Yellow}What do you want to do?${NC}"
    
    read choice
    
    case $choice in
        1)  echo -e "${Green}Starting server...${NC}"
            java -Xms128M -XX:MaxRAMPercentage=95.0 -Dterminal.jline=false -Dterminal.ansi=true -jar server.jar
            ui
            ;;
        2)  echo -e "${Yellow}Enter URL to download server.jar:${NC}"
            read uri
            if [ -f "server.jar" ]; then
                rm server.jar
            fi
            echo -e "${Blue}Pulling file...${NC}"
            wget -O server.jar "$uri"
            echo -e "${Green}Pull complete${NC}"
            ui
            ;;
        3)  cd /app/data
            filename="backup_$(date +%Y%m%d_%H%M%S).zip"
            echo -e "${Blue}Creating backup: $filename${NC}"
            zip -r "$filename" ./*
            
            # Setup Apache for Alpine
            mkdir -p /var/www/localhost/htdocs/download
            cp "$filename" /var/www/localhost/htdocs/download/
            
            # Start Apache via OpenRC instead of systemd
            /etc/init.d/apache2 start
            
            echo -e "${Green}Backup ready at: http://$(hostname -I | awk '{print $1}')/download/$filename${NC}"
            echo -e "${Yellow}Type 'done' when file download is complete:${NC}"
            
            read confirmation
            if [ "$confirmation" = "done" ]; then
                /etc/init.d/apache2 stop
                echo -e "${Green}Apache stopped${NC}"
            fi
            ui
            ;;
        4)  echo -e "${Green}Exiting to shell...${NC}"
            exit 0
            ;;
        *)  echo -e "${Red}Error: Please enter a valid option${NC}"
            ui
            ;;
    esac
}

# Run the UI
ui