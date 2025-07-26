#!/bin/bash
# RAINOVPN TUNNEL MANAGER Installer
# Author: Pooya Baghrei

set -e

GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"; NC="\e[0m"
SERVICE_FILE="/etc/systemd/system/rainovpn.service"
INSTALL_PATH="/usr/local/bin/rainovpn.sh"
RAW_URL="https://raw.githubusercontent.com/pooyaserver/tunnel/main/rainovpn.sh"

banner() {
  echo -e "${GREEN}"
  echo "============================================================"
  echo "    RAINOVPN TUNNEL MANAGER - INSTALLER"
  echo "============================================================"
  echo -e "${NC}"
}

check_root() {
  if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root${NC}"
    exit 1
  fi
}

install_script() {
  echo -e "${YELLOW}⬇ Downloading script...${NC}"
  curl -Ls $RAW_URL -o $INSTALL_PATH
  chmod +x $INSTALL_PATH
  echo -e "${GREEN}✅ Installed at $INSTALL_PATH${NC}"
}

install_systemd() {
  echo -e "${YELLOW}Do you want to enable autostart at boot? (y/n):${NC}"
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    cat > $SERVICE_FILE <<EOF
[Unit]
Description=RAINOVPN TUNNEL Auto-Start
After=network.target

[Service]
Type=oneshot
ExecStart=$INSTALL_PATH --autostart
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reexec
    systemctl enable RAINOVPN-tunnel.service
    echo -e "${GREEN}✅ Systemd service installed and enabled.${NC}"
  else
    echo -e "${YELLOW}⚠ Skipping systemd installation.${NC}"
  fi
}

run_script() {
  echo -e "${YELLOW}▶ Running RAINOVPN TUNNEL MANAGER...${NC}\n"
  $INSTALL_PATH
}

banner
check_root
install_script
install_systemd
run_script