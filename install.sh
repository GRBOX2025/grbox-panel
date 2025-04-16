#!/bin/bash

set -e
echo "[GRBOX] Установка финальной версии..."

# Обновление и зависимости
apt update && apt upgrade -y
apt install -y curl wget unzip git docker.io docker-compose gnupg2 golang postgresql postgresql-contrib caddy

# Настройка PostgreSQL
echo "[GRBOX] Настройка PostgreSQL..."
sudo -u postgres psql -c "CREATE USER grbox WITH PASSWORD 'grboxpass';"
sudo -u postgres psql -c "CREATE DATABASE grboxdb OWNER grbox;"

# Создание рабочей директории
mkdir -p /opt/grbox
cp -r backend /opt/grbox/
cp -r telegram_bot /opt/grbox/
cp -r frontend /opt/grbox/
cp grbox-panel.service /etc/systemd/system/grbox-panel.service
cp Caddyfile /etc/caddy/Caddyfile

# Компиляция backend
echo "[GRBOX] Сборка backend..."
cd /opt/grbox/backend
go mod init grbox || true
go mod tidy
go build -o grbox-panel

# Компиляция Telegram-бота
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
