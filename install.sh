#!/bin/bash

set -e
echo "[GRBOX] Установка финальной GRBOX Panel..."

# Установка зависимостей
apt update && apt install -y curl wget unzip gnupg2 golang

# Установка Caddy напрямую
echo "[GRBOX] Установка Caddy..."
wget https://github.com/caddyserver/caddy/releases/download/v2.7.6/caddy_2.7.6_linux_amd64.deb
dpkg -i caddy_2.7.6_linux_amd64.deb
rm caddy_2.7.6_linux_amd64.deb

# Подготовка директории
mkdir -p /opt/grbox
cd /opt/grbox

# Скачивание и распаковка панели
echo "[GRBOX] Загрузка панели..."
curl -L -o panel.zip https://grbox2025.github.io/grbox-panel/GRBOX_Panel_Final.zip
unzip panel.zip
rm panel.zip

# Настройка systemd
echo "[GRBOX] Установка службы..."
cp grbox-panel.service /etc/systemd/system/grbox-panel.service
chmod +x backend/main.go

# Компиляция backend
echo "[GRBOX] Сборка backend..."
cd backend
go mod init grbox || true
go mod tidy
go build -o grbox-panel
chmod +x grbox-panel

# Активация сервиса
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable grbox-panel
systemctl start grbox-panel

# Настройка Caddy
echo "[GRBOX] Настройка HTTPS через Caddy..."
cp /opt/grbox/Caddyfile /etc/caddy/Caddyfile
systemctl restart caddy

echo "[GRBOX] Установка завершена ✅"
echo "Открывай: http://<твой_IP>:2053 или https://<твой_IP> (если Caddy работает)"
