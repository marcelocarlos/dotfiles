#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# Setup git configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/utils.sh"

# ------------------------------------------------------------------------------
# Setup git config
# ------------------------------------------------------------------------------
print_h1 "Setting up Git"

# Point global git config to our config
print_h2 "Configuring git to use dotfiles gitconfig"
git config --global include.path "$DOTFILES_DIR/config/git/gitconfig"
print_green "Git config set to use $DOTFILES_DIR/config/git/gitconfig"

# Set excludesfile dynamically (can't use variables in gitconfig)
git config --global core.excludesfile "$DOTFILES_DIR/config/git/gitignore"
print_green "Git global gitignore set to $DOTFILES_DIR/config/git/gitignore"

# ------------------------------------------------------------------------------
# Setup git-secrets
# ------------------------------------------------------------------------------
if command_exists git-secrets; then
    print_h2 "Registering AWS patterns with git-secrets"
    git secrets --register-aws --global 2>/dev/null || true
    print_green "git-secrets configured"
fi

# ------------------------------------------------------------------------------
# Setup local git config (email, GPG)
# ------------------------------------------------------------------------------
print_h2 "Setting up local git configuration"

SETUP_GIT_CONFIG='n'
if [ -f "$HOME/.gitconfig.local" ]; then
    read -r -p "$HOME/.gitconfig.local already exists, do you want to re-create it? [y/N] " ANSWER
    if [ "$ANSWER" == "y" ] || [ "$ANSWER" == "Y" ]; then
        SETUP_GIT_CONFIG='y'
    fi
else
    SETUP_GIT_CONFIG='y'
fi

if [ "$SETUP_GIT_CONFIG" == 'y' ]; then
    read -r -p "Git email address: " GIT_EMAIL
    echo -e "[user]\nemail = $GIT_EMAIL" > ~/.gitconfig.local
    print_green "Git email configured"

    read -r -p "Setup GPG signing? [y/N] " ANSWER
    if [ "$ANSWER" == "y" ] || [ "$ANSWER" == "Y" ]; then
        echo ""
        print_h2 "Available GPG keys:"
        gpg --list-secret-keys --keyid-format LONG
        echo ""
        read -r -p "GPG signing key (value from 'sec', after '/'): " GPG_KEY
        if [ -n "$GPG_KEY" ]; then
            {
                echo "signingkey = $GPG_KEY"
                echo -e "[commit]\ngpgsign = true"
                echo -e "[gpg]\nprogram = gpg"
            } >> ~/.gitconfig.local
            print_green "GPG signing configured"
        fi
    fi
else
    print_green "Skipping local git config setup"
fi

print_success "Done"
