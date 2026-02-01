#!/bin/bash
set -euo pipefail

# Ask for sudo once
sudo -v

# Keep-alive: update sudo timestamp until script finishes
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# -----------------------------
# Core system packages
# -----------------------------
PACMAN_PKGS=(
  bind
  bitwarden
  bitwarden-cli
  graphviz
  helm
  kubectl
  python-distro
  python-setuptools
  rclone
  tmux
  trash-cli
  wp-cli
  composer
  php
  php-fpm
  php-gd
  php-imagick
  php-pgsql
  php-redis
  php-sqlite
  php-sodium
)

YAY_PKGS=(
  antigen
  brave-bin
  bruno-bin
  cheese
  cloudfleet-cli
  downgrade
  jetbrains-toolbox
  lens-bin
  mattermost-desktop-bin
  mycli
  ssh-import-id
  vesktop-bin
  zsh
)

echo "Installing core packages..."
sudo pacman -S --noconfirm --needed "${PACMAN_PKGS[@]}"
yay -S --noconfirm --needed "${YAY_PKGS[@]}"
if ! command -v sshm >/dev/null 2>&1
then
  # Install sshm
  curl -sSL https://raw.githubusercontent.com/Gu1llaum-3/sshm/main/install/unix.sh | bash
fi

# -----------------------------
# Authorised SSH keys
# -----------------------------
rm -f ~/.ssh/authorized_keys
ssh-import-id gh:Jamesking56

# -----------------------------
# Enable SSH server over LAN
# -----------------------------
sudo ufw allow from 192.168.0.0/24 to any port 22
sudo systemctl enable sshd
sudo systemctl start sshd

# -----------------------------
# Docker Containers
# -----------------------------
declare -A DOCKER_CONTAINERS=(
  [mariadb11]="omarchy-install-docker-dbs MariaDB"
  [postgres18]="omarchy-install-docker-dbs PostgreSQL"
  [mailhog]="docker run --name mailhog -d -it --restart=always -p 8025:8025 -p 1025:1025 mailhog/mailhog"
)

echo "Setting up Docker containers..."
for container in "${!DOCKER_CONTAINERS[@]}"; do
  if [ -z "$(docker ps -a -q -f name=$container)" ]; then
    eval "${DOCKER_CONTAINERS[$container]}"
  fi
done

# -----------------------------
# Global Composer packages
# -----------------------------
echo "Installing global Composer packages..."
composer global require --no-interaction \
  laravel/installer

# -----------------------------
# PHP Versions and Extensions
# -----------------------------

# Enable Redis for main php package
echo "extension=redis.so" | sudo tee /etc/php/conf.d/redis.ini > /dev/null
sudo sed -i 's/;extension=igbinary/extension=igbinary/' /etc/php/conf.d/igbinary.ini
sudo sed -i 's/;extension=redis/extension=redis/' /etc/php/conf.d/redis.ini

PHP_VERSIONS=(84 83 82)

# Extensions that are safe to bulk-install
SAFE_EXTENSIONS=(bcmath cli curl dom exif fileinfo fpm gd iconv intl mbstring mysql openssl pcntl pdo pecl pgsql phar posix simplexml sqlite sockets sodium tokenizer xml xmlreader xmlwriter zip)

# Extensions that often fail and need manual installation
TRICKY_EXTENSIONS=(redis xdebug)

echo "Installing PHP base packages..."
for ver in "${PHP_VERSIONS[@]}"; do
  yay -S --noconfirm --needed "php${ver}"
done

echo "Installing safe PHP extensions..."
for ver in "${PHP_VERSIONS[@]}"; do
  pkgs=()
  for ext in "${SAFE_EXTENSIONS[@]}"; do
    pkgs+=("php${ver}-${ext}")
  done
  yay -S --noconfirm --needed "${pkgs[@]}"
done

echo "Installing tricky PHP extensions (may require manual intervention)..."
for ver in "${PHP_VERSIONS[@]}"; do
  for ext in "${TRICKY_EXTENSIONS[@]}"; do
    # Ignore failures for now, allow manual retry
    yay -S --noconfirm --needed "php${ver}-${ext}" --mflags --nocheck || echo "Failed to install php${ver}-${ext}, please install manually."
  done
done

echo "Install redis via PECL for PHP 8.4 (due to missing php84-redis package)"
if [ ! -f /etc/php84/conf.d/redis.ini ]; then
  yes '' | sudo pecl84 install --soft redis || true
  echo "extension=redis.so" | sudo tee /etc/php84/conf.d/redis.ini > /dev/null
fi

# -----------------------------
# Remove unwanted packages
# -----------------------------
REMOVE_PACKAGES=(
  1password
  1password-beta
  1password-cli
  alacritty
  omarchy-chromium
  signal-desktop
  spotify
  typora
  xournalpp
)

for pkg in "${REMOVE_PACKAGES[@]}"; do
  if pacman -Q "$pkg" &>/dev/null; then
    sudo pacman -Rns --noconfirm "$pkg"
  fi
done

# -----------------------------
# Remove unwanted web apps
# -----------------------------
REMOVE_WEB_APPS=(
  Basecamp
  Discord
  Figma
  Fizzy
  HEY
)

for app in "${REMOVE_WEB_APPS[@]}"; do
  omarchy-webapp-remove "$app"
done

# -----------------------------
# Setup valet-linux
# -----------------------------
if ! command -v valet; then
  composer global require cpriego/valet-linux
  valet install
fi
sudo rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
valet park ~/Work
# Setup Cloudflare DNS for anything outside of valet 
sudo tee /etc/dnsmasq.d/valet-upstream.conf > /dev/null <<'EOF'
server=1.1.1.1
server=1.0.0.1
EOF
sudo tee /etc/dnsmasq.d/valet.conf > /dev/null <<'EOF'
address=/test/127.0.0.1
listen-address=127.0.0.1
bind-interfaces
EOF
sudo systemctl restart dnsmasq
sudo resolvectl flush-caches
valet restart

# -----------------------------
# Finish
# -----------------------------
echo
gum spin --spinner "globe" --title "Packages updated!" -- bash -c 'read -n 1 -s'
