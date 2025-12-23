#!/bin/bash
set -euo pipefail

# -----------------------------
# Core system packages
# -----------------------------
PACMAN_PKGS=(
  bitwarden
  bitwarden-cli
  cheese
  graphviz
  rclone
  tmux
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
  cloudfleet-cli
  downgrade
  jetbrains-toolbox
  lens-bin
  mattermost-desktop-bin
  mycli
  vesktop-bin
  zsh
)

echo "Installing core packages..."
sudo pacman -S --noconfirm --needed "${PACMAN_PKGS[@]}"
yay -S --noconfirm --needed "${YAY_PKGS[@]}"

# -----------------------------
# Docker Containers
# -----------------------------
declare -A DOCKER_CONTAINERS=(
  [mariadb11]="omarchy-install-docker-dbs MariaDB"
  [postgres17]="omarchy-install-docker-dbs PostgreSQL"
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
  laravel/installer \
  cpriego/valet-linux

# -----------------------------
# PHP Versions and Extensions
# -----------------------------
PHP_VERSIONS=(84 83 82)

# Extensions that are safe to bulk-install
SAFE_EXTENSIONS=(bcmath cli curl dom exif fileinfo fpm gd iconv intl mbstring mysql openssl pcntl pdo pgsql phar posix simplexml sqlite sockets sodium tokenizer xml xmlreader xmlwriter)

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

# -----------------------------
# Remove unwanted packages
# -----------------------------
REMOVE_PACKAGES=(
  1password
  alacritty
  signal-desktop
)

for pkg in "${REMOVE_PACKAGES[@]}"; do
  if pacman -Q "$pkg" &>/dev/null; then
    sudo pacman -Rns --noconfirm "$pkg"
  fi
done

# -----------------------------
# Finish
# -----------------------------
echo
gum spin --spinner "globe" --title "Packages updated!" -- bash -c 'read -n 1 -s'
