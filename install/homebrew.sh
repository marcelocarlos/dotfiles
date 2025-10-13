#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# Install Homebrew and applications from Brewfile

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/utils.sh"

# ------------------------------------------------------------------------------
# Install Homebrew
# ------------------------------------------------------------------------------
print_h1 "Installing Homebrew"

if ! command -v brew &> /dev/null; then
    print_h2 "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    print_green "Homebrew already installed"
fi

# ------------------------------------------------------------------------------
# Install applications from Brewfile
# ------------------------------------------------------------------------------
print_h1 "Installing Applications from Brewfile"

if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    print_yellow "IMPORTANT: Open the App Store and login before continuing."
    print_yellow "Press <enter> to continue..."
    read -r

    cd "$DOTFILES_DIR"
    brew bundle
    print_green "Applications installed successfully"
else
    print_yellow "Warning: Brewfile not found at $DOTFILES_DIR/Brewfile"
fi

print_success "Done"
