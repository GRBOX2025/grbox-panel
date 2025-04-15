#!/bin/bash

set -e

echo "[GRBOX] Установка начата..."

# Обновление системы и установка зависимостей
apt update && apt upgrade -y
apt install -y curl wget unzip docker.io docker-compose debian-keyring debian-archive-keyring apt-transport-https gnupg

# Установка Caddy из официального репозитория
echo "[GRBOX] Установка Caddy..."
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
echo "deb [signed-by=/usr/share/keyrings/caddy-archive-keyring.gpg] https://dl.cloudsmith.io/public/caddy/stable/deb/debian all main" > /etc/apt/sources.list.d/caddy.list
apt update
apt install -y caddy

# Создание рабочей директории
mkdir -p /opt/grbox
cd /opt/grbox

# Загрузка и распаковка архива
echo "[GRBOX] Загрузка панели..."
curl -L -o GRBOX_Panel.zip https://yourdomain.com/GRBOX_Panel.zip
unzip GRBOX_Panel.zip
rm GRBOX_Panel.zip

# Настройка systemd
echo "[GRBOX] Настройка systemd..."
cp grbox-panel.service /etc/systemd/system/grbox-panel.service
chmod +x grbox-panel.sh
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable grbox-panel
systemctl start grbox-panel

# Запуск Telegram-бота (если есть)
if [ -f "telegram_bot/install.sh" ]; then
    echo "[GRBOX] Установка Telegram-бота..."
    bash telegram_bot/install.sh
fi

# Настройка Caddy
echo "[GRBOX] Настройка HTTPS через Caddy..."
cat <<EOF > /etc/caddy/Caddyfile
:443 {
    reverse_proxy localhost:2053
    encode gzip
    tls internal
}
EOF
systemctl restart caddy

echo "[GRBOX] Установка завершена."
echo "Панель доступна на: https://<ваш_домен> (или https://IP)"
