#!/bin/bash
# RAINOVPN TUNNEL MANAGER Installer
# Author: Pooya Baghrei

set -e

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
NC="\e[0m"

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
    echo -e "${RED}❌ لطفاً اسکریپت را به عنوان root اجرا کنید${NC}"
    exit 1
  fi
}

install_script() {
  echo -e "${YELLOW}⬇ در حال دانلود اسکریپت از GitHub...${NC}"
  if ! curl -Ls "$RAW_URL" -o "$INSTALL_PATH"; then
    echo -e "${RED}❌ خطا در دانلود اسکریپت. اتصال اینترنت را بررسی کنید.${NC}"
    exit 1
  fi
  chmod +x "$INSTALL_PATH"
  echo -e "${GREEN}✅ نصب شد: $INSTALL_PATH${NC}"
}

install_systemd() {
  echo -e "${YELLOW}⚙ آیا می‌خواهید اسکریپت هنگام بوت اجرا شود؟ (y/n):${NC}"
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    cat > "$SERVICE_FILE" <<EOF
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

    systemctl daemon-reload
    systemctl enable rainovpn.service

    if systemctl is-enabled --quiet rainovpn.service; then
      echo -e "${GREEN}✅ سرویس systemd با موفقیت فعال شد.${NC}"
    else
      echo -e "${RED}❌ خطا در فعال‌سازی سرویس.${NC}"
    fi
  else
    echo -e "${YELLOW}⚠ راه‌اندازی خودکار صرف‌نظر شد.${NC}"
  fi
}

run_script() {
  echo -e "${YELLOW}▶ در حال اجرای RAINOVPN TUNNEL MANAGER...${NC}\n"
  "$INSTALL_PATH"
}

# اجرای مراحل
banner
check_root
install_script
install_systemd
run_script
