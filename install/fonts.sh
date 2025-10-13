#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# Install Powerline fonts for terminal use

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

# ------------------------------------------------------------------------------
# Powerline Fonts Installation
# ------------------------------------------------------------------------------
print_h1 "📦 Installing Powerline Fonts"

# macOS installs fonts to ~/Library/Fonts
FONTS_DIR="$HOME/Library/Fonts"

# Check if Meslo Powerline fonts are already installed
if ls "$FONTS_DIR"/*Powerline* 1> /dev/null 2>&1; then
    print_success "Powerline fonts already installed in $FONTS_DIR"
else
    print_step "Downloading and installing Powerline fonts"

    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR" || exit 1

    print_info "Cloning powerline/fonts repository..."
    if git clone https://github.com/powerline/fonts.git --depth=1 >/dev/null 2>&1; then
        cd fonts || exit 1

        print_info "Running font installer..."
        if ./install.sh >/dev/null 2>&1; then
            print_success "Powerline fonts installed successfully"
        else
            print_error "Font installation script failed"
            print_yellow "Try installing manually: git clone https://github.com/powerline/fonts.git && cd fonts && ./install.sh"
            cd "$SCRIPT_DIR" || exit 1
            rm -rf "$TEMP_DIR"
            exit 1
        fi

        cd "$SCRIPT_DIR" || exit 1
    else
        print_error "Failed to clone fonts repository"
        print_yellow "Check your internet connection and try again"
        cd "$SCRIPT_DIR" || exit 1
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # Cleanup
    rm -rf "$TEMP_DIR"
fi

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
print_separator
print_h1 "🚀 Powerline Fonts Ready!"
echo ""
print_success "Fonts installed to: $FONTS_DIR"
echo ""
print_info "Next steps:"
echo "  1. Open your terminal preferences (iTerm2, Terminal.app, VSCode, etc.)"
echo "  2. Select a Powerline font for your terminal profile"
echo ""
print_info "Recommended fonts:"
echo "  • Meslo LG M for Powerline (recommended)"
echo "  • Meslo LG S for Powerline"
echo "  • DejaVu Sans Mono for Powerline"
echo "  • Roboto Mono for Powerline"
print_separator
