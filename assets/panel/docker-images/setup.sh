#!/bin/sh

# Colors for UI
Blue='\033[0;34m'
White='\033[0;37m'
Green='\033[0;32m'
Red='\033[0;31m'
Yellow='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${Blue}Setting up environment...${NC}"

# Navigate to app directory
cd /app/data/

# Install necessary packages (do this only once)
echo -e "${Yellow}Installing required packages...${NC}"
apk add --no-cache --update bash wget zip unzip apache2  openjdk21
dos2unix setup.sh
rm -rf /app/data/server.jar /app/data/README.md

# Extract setup files if needed
if [ -f "setup.zip" ]; then
    echo -e "${Blue}Extracting setup files...${NC}"
    mkdir -p setup
    mv setup.zip setup/
    cd setup
    unzip -o setup.zip
    cd ..
    
    # Set up web directory
    echo -e "${Blue}Setting up web directory...${NC}"
    mkdir -p /var/www/localhost/htdocs/download
    if [ -d "setup" ] && [ "$(ls -A setup)" ]; then
        cp -r setup/* /var/www/localhost/
    fi
fi

# Main UI function
ui() {
    clear
    echo -e "${Yellow}===== SERVER MANAGEMENT MENU =====${NC}"
    echo -e "${Blue}[1]${NC} Start server"
    echo -e "${Blue}[2]${NC} Update server"
    echo -e "${Blue}[3]${NC} Download backup zip"
    echo -e "${Blue}[4]${NC} Use shell"
    echo
    echo -e "${Yellow}What do you want to do?${NC}"
   
    read choice
   
    case $choice in
        1)  echo -e "${Green}Starting server...${NC}"
            java -Xms128M -XX:MaxRAMPercentage=95.0 -Dterminal.jline=false -Dterminal.ansi=true -jar server.jar
            echo -e "${Yellow}Server stopped. Returning to menu...${NC}"
            ui
            ;;
            
        2)  echo -e "${Yellow}Enter URL to download server.jar:${NC}"
            read uri
            if [ -z "$uri" ]; then
                echo -e "${Red}No URL provided. Returning to menu.${NC}"
                sleep 2
                ui
            fi
            
            if [ -f "server.jar" ]; then
                echo -e "${Blue}Backing up existing server.jar...${NC}"
                mv server.jar server.jar.backup
            fi
            
            echo -e "${Blue}Downloading server.jar...${NC}"
            if wget -O server.jar "$uri"; then
                echo -e "${Green}Download complete!${NC}"
                if [ -f "server.jar.backup" ]; then
                    echo -e "${Blue}Removing backup file...${NC}"
                    rm server.jar.backup
                fi
            else
                echo -e "${Red}Download failed!${NC}"
                if [ -f "server.jar.backup" ]; then
                    echo -e "${Blue}Restoring backup...${NC}"
                    mv server.jar.backup server.jar
                fi
            fi
            
            sleep 2
            ui
            ;;
            
        3)  cd /app/data
            filename="backup_$(date +%Y%m%d_%H%M%S).zip"
            echo -e "${Blue}Creating backup: $filename${NC}"
            
            # Exclude unnecessary files from backup
            zip -r "$filename" ./* -x "*.zip" -x "setup/*"
           
            # Copy to web directory
            echo -e "${Blue}Setting up download...${NC}"
            mkdir -p /var/www/localhost/htdocs/download
            cp "$filename" /var/www/localhost/htdocs/download/
           
            # Start Apache
            echo -e "${Blue}Starting web server...${NC}"
            /etc/init.d/apache2 start
           
            # Get IP address more reliably
            ip_address=$(hostname -I 2>/dev/null | awk '{print $1}')
            if [ -z "$ip_address" ]; then
                ip_address=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v "127.0.0.1" | head -n 1)
            fi
            
            echo -e "${Green}Backup ready at: http://$ip_address/download/$filename${NC}"
            echo -e "${Yellow}Type 'done' when file download is complete:${NC}"
           
            read confirmation
            if [ "$confirmation" = "done" ]; then
                /etc/init.d/apache2 stop
                echo -e "${Green}Web server stopped${NC}"
            fi
            
            sleep 2
            ui
            ;;
            
        4)  echo -e "${Green}Exiting to shell...${NC}"
            exit 0
            ;;
            
        *)  echo -e "${Red}Error: Please enter a valid option${NC}"
            sleep 2
            ui
            ;;
    esac
}

# Check if server.jar exists
if [ ! -f "server.jar" ]; then
    echo -e "${Yellow}Warning: server.jar not found. You may need to download it using option 2.${NC}"
    sleep 2
fi

# Run the UI
ui