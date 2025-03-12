#!/usr/bin/env bash

# Colors for UI
Blue='\033[0;34m'
White='\033[0;37m'
Green='\033[0;32m'
Red='\033[0;31m'
Yellow='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${Blue}Setting up environment...${NC}"

# Navigate to app directory
cd /app/data/ || { echo -e "${Red}Failed to change to /app/data/ directory${NC}"; exit 1; }

# Install necessary packages (do this only once)
echo -e "${Yellow}Installing required packages...${NC}"
apk add --no-cache --update \
    bash \
    wget \
    zip \
    unzip \
    apache2 \
    openjdk21 \
    gcc \
    make \
    zlib-dev \
    libffi-dev \
    openssl-dev \
    musl-dev \
    dos2unix \
    python3 \
    py3-pip || { echo -e "${Red}Failed to install packages${NC}"; exit 1; }
# install everything adn set it up
dos2unix /app/data/setup.sh  || echo -e "${Yellow}Warning: dos2unix failed, but continuing...${NC}"
mkdir /app/tools
chmod 755 /app/tools
mkdir /app/backups
chmod 755 /app/backups
mv /app/data/setup.sh /app/tools
wget -O files.py https://raw.githubusercontent.com/g-flame-oss/py-file-explorer/refs/heads/main/main.py
mv /app/data/files.py /app/tools

sleep 2

# Function for downloading server.jar with progress
download_server() {
    local uri="$1"
    
    if [ -f "server.jar" ]; then
        echo -e "${Blue}Backing up existing server.jar...${NC}"
        mv server.jar server.jar.backup
    fi
    
    echo -e "${Blue}Downloading server.jar...${NC}"
    if wget --progress=bar:force -O server.jar "$uri"; then
        echo -e "${Green}Download complete!${NC}"
        if [ -f "server.jar.backup" ]; then
            echo -e "${Blue}Removing backup file...${NC}"
            rm server.jar.backup
        fi
        return 0
    else
        echo -e "${Red}Download failed!${NC}"
        if [ -f "server.jar.backup" ]; then
            echo -e "${Blue}Restoring backup...${NC}"
            mv server.jar.backup server.jar
        fi
        return 1
    fi
}

# Function for creating backup with sequential naming
create_backup() {
    cd /app/data || { echo -e "${Red}Failed to change to /app/data/ directory${NC}"; return 1; }
    
    # Find the next available backup number
    local backup_num=1
    while [ -f "/app/data/backup${backup_num}.zip" ]; do
        backup_num=$((backup_num + 1))
    done
    
    local filename="backup${backup_num}.zip"
    echo -e "${Blue}Creating backup: $filename${NC}"
    
    # Zip the entire /app/data directory
    cd /app || { echo -e "${Red}Failed to change to /app directory${NC}"; return 1; }
    if zip -r "/app/data/$filename" data; then
        echo -e "${Green}Backup created successfully: $filename${NC}"
        # Return to /app/data directory after creating backup
        cd /app/data || { echo -e "${Red}Failed to return to /app/data directory${NC}"; return 1; }
    else
        echo -e "${Red}Failed to create backup file${NC}"
        # Return to /app/data directory even if backup fails
        cd /app/data || { echo -e "${Red}Failed to return to /app/data directory${NC}"; return 1; }
        return 1
    fi
    mv backup* /app/backups/
}

# Function for running diagnostics
run_diagnostics() {
    echo -e "${Blue}Running diagnostics...${NC}"
    echo -e "${Yellow}System Information:${NC}"
    uname -a
    
    echo -e "\n${Yellow}Disk Usage:${NC}"
    df -h
    
    echo -e "\n${Yellow}Memory Usage:${NC}"
    free -h
    
    echo -e "\n${Yellow}Java Version:${NC}"
    java -version
    
    echo -e "\n${Yellow}Python Version:${NC}"
    python3 --version
    
    echo -e "\n${Yellow}Server.jar Status:${NC}"
    if [ -f "server.jar" ]; then
        echo -e "${Green}server.jar exists ($(du -h server.jar | cut -f1))${NC}"
    else
        echo -e "${Red}server.jar does not exist${NC}"
    fi
    
    echo -e "\n${Yellow}Diagnostics complete.${NC}"
    read -p "Press Enter to continue..."
}

# Main UI function
ui() {
    clear
    echo -e "${Yellow}===== SERVER MANAGEMENT MENU =====${NC}"
    echo -e "${Blue}[1]${NC} Start server"
    echo -e "${Blue}[2]${NC} Update server"
    echo -e "${Blue}[3]${NC} Download backup zip"
    echo -e "${Blue}[4]${NC} Use shell"
    echo -e "${Blue}[5]${NC} Run diagnostics"
    echo -e "${Blue}[6]${NC} Stop container"
    echo -e "${Yellow}What do you want to do?${NC}"
   
    read -r choice
   
    case $choice in
        1)  echo -e "${Green}Starting server...${NC}"
            if [ ! -f "server.jar" ]; then
                echo -e "${Red}Error: server.jar not found. Please download it first (option 2).${NC}"
                sleep 3
                ui
            fi
            java -Xms128M -XX:MaxRAMPercentage=95.0 -Dterminal.jline=false -Dterminal.ansi=true -jar server.jar
            echo -e "${Yellow}Server stopped. Returning to menu...${NC}"
            ui
            ;;
            
        2)  echo -e "${Yellow}Enter URL to download server.jar:${NC}"
            read -r uri
            if [ -z "$uri" ]; then
                echo -e "${Red}No URL provided. Returning to menu.${NC}"
                sleep 2
                ui
            fi
            
            download_server "$uri"
            sleep 2
            ui
            ;;
            
        3)  create_backup
            echo -e "${Yellow}Type 'done' when file download is complete:${NC}"
            python /app/tools/files.py
            sleep 5
            ui
            ;;
            
        4)  echo -e "${Green}Exiting to shell...${NC}"
            bash
            ui
            ;;
        
        5)  run_diagnostics
            ui
            ;;

        6)  echo -e "${Blue}Exiting container...${NC}" 
            exit 
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