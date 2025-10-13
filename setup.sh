#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# Main setup script - orchestrates dotfiles installation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

source install/utils.sh

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
print_h1 "Dotfiles Setup"

# Check if .dotfiles.conf exists, if not create from example
if [ ! -f .dotfiles.conf ]; then
    print_yellow "No .dotfiles.conf found. Creating from .dotfiles.conf.example"
    cp .dotfiles.conf.example .dotfiles.conf
    print_green "Created .dotfiles.conf"
    echo ""
    print_yellow "Please edit .dotfiles.conf to customize your installation"
    print_yellow "Uncomment the features you want to enable, then re-run this script"
    echo ""
    exit 0
fi

# Load configuration
source .dotfiles.conf

# ------------------------------------------------------------------------------
# Parse command line arguments
# ------------------------------------------------------------------------------
usage() {
    cat << EOF
Usage: $(basename "$0") [options]

Options:
    -h          Show this help menu

Configuration:
    Edit .dotfiles.conf to enable/disable features
    Uncomment lines to enable specific installations and modules

EOF
}

while getopts "h" OPTION; do
    case $OPTION in
        h)
            usage
            exit 0
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done

# ------------------------------------------------------------------------------
# Run installation scripts based on configuration
# ------------------------------------------------------------------------------

# Core installations
if [[ "${INSTALL_HOMEBREW:-}" == "true" ]]; then
    bash install/homebrew.sh
fi

if [[ "${INSTALL_BASH:-}" == "true" ]]; then
    bash install/bash.sh
fi

if [[ "${INSTALL_GIT_TOOLS:-}" == "true" ]]; then
    bash install/git.sh
fi

# Language environments
if [[ "${INSTALL_PYTHON:-}" == "true" ]]; then
    bash install/python.sh
fi

if [[ "${INSTALL_NODE:-}" == "true" ]]; then
    bash install/node.sh
fi

if [[ "${INSTALL_GO:-}" == "true" ]]; then
    bash install/go.sh
fi

if [[ "${INSTALL_RUBY:-}" == "true" ]]; then
    bash install/ruby.sh
fi

# Applications
if [[ "${INSTALL_ITERM:-}" == "true" ]]; then
    bash install/iterm.sh
fi

if [[ "${INSTALL_FONTS:-}" == "true" ]]; then
    bash install/fonts.sh
fi

# macOS System Preferences
if [[ "${INSTALL_MACOS_SETTINGS:-}" == "true" ]]; then
    bash install/macos-settings.sh
fi

# Features
if [[ "${ENABLE_GPG:-}" == "true" ]]; then
    bash install/gpg.sh
fi

if [[ "${ENABLE_GCP:-}" == "true" ]]; then
    bash install/gcp.sh
fi

# QuickLook plugins (run if any were installed via Brewfile)
if command_exists qlmanage && [ -d "$HOME/Library/QuickLook" ]; then
    bash install/quicklook.sh
fi

# ------------------------------------------------------------------------------
# Git Hooks (Optional)
# ------------------------------------------------------------------------------
if [[ "${SETUP_GIT_HOOKS:-}" == "true" ]]; then
    echo ""
    print_h2 "Setting up git hooks for secret scanning"
    bash scripts/setup-git-hooks.sh
fi

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
echo ""
print_h1 "Setup Complete!"
echo ""
print_green "Your dotfiles have been configured successfully."
echo ""
print_yellow "Next steps:"
echo "  1. Restart your terminal or run: source ~/.bash_profile"
echo "  2. Customize ~/.bashrc.local for machine-specific settings"
echo "  3. Edit .dotfiles.conf to enable/disable features"
echo ""

# Suggest setting up git hooks if not already done
if [[ "${SETUP_GIT_HOOKS:-}" != "true" ]] && [ ! -f .git/hooks/pre-commit ]; then
    print_yellow "Optional: Setup git hooks to prevent committing secrets"
    echo "  bash scripts/setup-git-hooks.sh"
    echo ""
fi

print_green "Enjoy your new environment!"
