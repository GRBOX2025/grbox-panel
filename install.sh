#!/bin/bash

set -e
echo "[GRBOX] Установка началась..."

# Обновление и зависимости
apt update && apt upgrade -y
apt install -y curl wget unzip git docker.io docker-compose gnupg2 golang postgresql postgresql-contrib

# Установка Caddy вручную (через .deb)
echo "[GRBOX] Установка Caddy..."
wget https://github.com/caddyserver/caddy/releases/download/v2.7.6/caddy_2.7.6_linux_amd64.deb
dpkg -i caddy_2.7.6_linux_amd64.deb || apt --fix-broken install -y
rm caddy_2.7.6_linux_amd64.deb

# Настройка PostgreSQL
echo "[GRBOX] Настройка PostgreSQL..."
sudo -u postgres psql -c "CREATE USER grbox WITH PASSWORD 'grboxpass';"
sudo -u postgres psql -c "CREATE DATABASE grboxdb OWNER grbox;"

# Скачиваем и распаковываем GRBOX_Panel_Pro.zip
echo "[GRBOX] Загрузка панели..."
mkdir -p /opt/grbox
cd /opt/grbox
wget https://grbox2025.github.io/grbox-panel/GRBOX_Panel_Pro.zip -O panel.zip
unzip panel.zip
rm panel.zip

# Копируем системные файлы
cp grbox-panel.service /etc/systemd/system/grbox-panel.service
cp Caddyfile /etc/caddy/Caddyfile

# Сборка backend
echo "[GRBOX] Сборка backend..."
cd /opt/grbox/backend
go mod init grbox || true
go mod tidy
go build -o grbox-panel

# Сборка Telegram-бота
echo "[GRBOX] Сборка Telegram-бота..."
cd /opt/grbox/telegram_bot
go mod init grboxbot || true
go mod tidy
go build -o grbox-bot
nohup ./grbox-bot > /opt/grbox/telegram_bot/bot.log 2>&1 &

# Назначаем права и systemd
chmod +x /opt/grbox/backend/grbox-panel
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable grbox-panel
systemctl start grbox-panel

# Перезапуск Caddy
echo "[GRBOX] Перезапуск Caddy..."
systemctl restart caddy

echo "[GRBOX] Установка завершена!"
echo "Панель доступна на: https://<твой_IP>"
