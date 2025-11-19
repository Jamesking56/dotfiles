source /usr/share/zsh/share/antigen.zsh

antigen use oh-my-zsh

antigen bundles <<EOBUNDLES
    # Bundles from the default repo (robbyrussell's oh-my-zsh)
    command-not-found
    common-aliases
    composer
    copybuffer
    copyfile
    copypath
    docker
    encode64
    fzf
    gh
    git
    helm
    isodate
    laravel
    minikube
    mise
    nmap
    npm
    perms
    pip
    rclone
    redis-cli
    ssh-agent
    starship
    sudo
    systemd
    tmux
    transfer
    ufw
    web-search
    wp-cli
    zoxide

    # Third party bundles
    djui/alias-tips
    jasonmccreary/git-trim --branch=main
    jessarcher/zsh-artisan
    zsh-users/zsh-syntax-highlighting
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-completions
EOBUNDLES

antigen apply

zstyle :omz:plugins:ssh-agent agent-forwarding on
zstyle :omz:plugins:ssh-agent lifetime 4h

# History control
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE="${HISTSIZE}"

# Ensure command hashing if off for mise
set +h

source $HOME/.aliases
source ~/.local/share/omarchy/default/bash/functions
source ~/.local/share/omarchy/default/bash/envs

export PATH="$HOME/.config/composer/vendor/bin:$PATH"
