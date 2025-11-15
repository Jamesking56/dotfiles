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
    debian
    docker
    encode64
    gh
    git
    helm
    isodate
    laravel
    minikube
    nmap
    npm
    perms
    pip
    rclone
    redis-cli
    snap
    ssh-agent
    sudo
    systemd
    tmux
    transfer
    ubuntu
    ufw
    web-search
    wp-cli
    yarn

    # Third party bundles
    djui/alias-tips
    zsh-users/zsh-syntax-highlighting
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-completions
    jessarcher/zsh-artisan
    jasonmccreary/git-trim --branch=main
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
source ~/.local/share/omarchy/default/bash/prompt
source ~/.local/share/omarchy/default/bash/envs

source /usr/share/fzf/key-bindings.zsh

eval "$(starship init zsh)"

export PATH="$HOME/.config/composer/vendor/bin:$PATH"
