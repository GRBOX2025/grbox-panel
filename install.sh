#!/bin/bash

set -e

echo "[GRBOX] Установка начата..."

# Обновление системы и установка зависимостей
apt update && apt upgrade -y
apt install -y curl wget unzip docker.io docker-compose gnupg2

# Установка Caddy напрямую (без репозиториев)
echo "[GRBOX] Установка Caddy вручную (без репозиториев)..."
wget https://github.com/caddyserver/caddy/releases/download/v2.7.6/caddy_2.7.6_linux_amd64.deb
dpkg -i caddy_2.7.6_linux_amd64.deb
rm caddy_2.7.6_linux_amd64.deb

# Создание рабочей директории
mkdir -p /opt/grbox
cd /opt/grbox

# Загрузка и распаковка панели
echo "[GRBOX] Загрузка панели..."
curl -L -o GRBOX_Panel.zip https://grbox2025.github.io/grbox-panel/GRBOX_Panel.zip
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
