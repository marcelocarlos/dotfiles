#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# Setup iTerm2 with theme and fonts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/utils.sh"

# ------------------------------------------------------------------------------
# iTerm2 theme
# ------------------------------------------------------------------------------
print_h1 "Setting up iTerm2"

# Check for Powerline fonts
print_h2 "Checking Powerline fonts"
if ! ls "$HOME/Library/Fonts"/*Powerline* 1> /dev/null 2>&1; then
    print_yellow "Powerline fonts not installed"
    print_yellow "Run: bash install/fonts.sh to install fonts"
    echo ""
else
    print_green "Powerline fonts already installed"
fi

TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download One Dark theme
print_h2 "Downloading One Dark theme"
wget -q https://raw.githubusercontent.com/nathanbuchar/atom-one-dark-terminal/master/scheme/iterm/One%20Dark.itermcolors
if [ -f "One Dark.itermcolors" ]; then
    open "One Dark.itermcolors"
    print_green "One Dark theme downloaded and opened"
else
    print_yellow "Warning: Failed to download One Dark theme"
fi

# Cleanup
cd "$DOTFILES_DIR"
rm -rf "$TEMP_DIR"

# ------------------------------------------------------------------------------
# iTerm2 preferences
# ------------------------------------------------------------------------------
print_h2 "iTerm2 preferences location"

if [ -d "$DOTFILES_DIR/iterm" ]; then
    echo ""
    print_yellow "IMPORTANT: Open iTerm2 preferences (⌘,)"
    print_yellow "  Go to: General > Preferences"
    print_yellow "  Enable: 'Load preferences from a custom folder or URL'"
    print_yellow "  Set to: $DOTFILES_DIR/iterm"
    echo ""
else
    print_yellow "Warning: iterm preferences directory not found"
fi

print_success "Done"
