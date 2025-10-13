#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# Remove quarantine from QuickLook plugins

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

# ------------------------------------------------------------------------------
# QuickLook plugins
# ------------------------------------------------------------------------------
print_h1 "Setting up QuickLook plugins"

if [ -d "$HOME/Library/QuickLook" ]; then
    print_h2 "Removing quarantine from QuickLook plugins"
    xattr -d -r com.apple.quarantine ~/Library/QuickLook 2>/dev/null || true
    qlmanage -r
    print_green "QuickLook plugins configured"
else
    print_yellow "Warning: No QuickLook plugins directory found"
fi

print_success "Done"
