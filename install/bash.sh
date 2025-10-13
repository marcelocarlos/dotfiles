#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# Setup bash shell configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/utils.sh"

# ------------------------------------------------------------------------------
# Update default shell to Homebrew bash
# ------------------------------------------------------------------------------
print_h1 "Setting up Bash"

HOMEBREW_BASH="$(brew --prefix)/bin/bash"

# Add Homebrew bash to allowed shells if not already there
if ! contains_line "$HOMEBREW_BASH" "/etc/shells"; then
    print_h2 "Adding Homebrew bash to /etc/shells"
    echo "$HOMEBREW_BASH" | sudo tee -a /etc/shells
    print_green "Added $HOMEBREW_BASH to /etc/shells"
fi

# Change default shell to Homebrew bash
if [ "$SHELL" != "$HOMEBREW_BASH" ]; then
    print_h2 "Changing default shell to Homebrew bash"
    chsh -s "$HOMEBREW_BASH"
    print_green "Default shell changed to $HOMEBREW_BASH"
    print_yellow "Note: You may need to restart your terminal for this to take effect"
else
    print_green "Default shell is already set to Homebrew bash"
fi

# ------------------------------------------------------------------------------
# Setup bash_profile to source dotfiles
# ------------------------------------------------------------------------------
print_h2 "Configuring ~/.bash_profile"

BASH_PROFILE_SOURCE="source \"$DOTFILES_DIR/shell/bash_profile\""

if [ ! -f ~/.bash_profile ]; then
    echo "$BASH_PROFILE_SOURCE" > ~/.bash_profile
    print_green "Created ~/.bash_profile"
elif ! contains_line "$BASH_PROFILE_SOURCE" ~/.bash_profile; then
    echo "" >> ~/.bash_profile
    echo "$BASH_PROFILE_SOURCE" >> ~/.bash_profile
    print_green "Added dotfiles sourcing to ~/.bash_profile"
else
    print_green "$HOME/.bash_profile already sources dotfiles"
fi

# ------------------------------------------------------------------------------
# Setup inputrc (readline configuration)
# ------------------------------------------------------------------------------
print_h2 "Configuring ~/.inputrc (enables history search with arrow keys)"

if [ -f "$DOTFILES_DIR/config/misc/inputrc" ]; then
    ln -sf "$DOTFILES_DIR/config/misc/inputrc" ~/.inputrc
    print_green "inputrc configured - arrow keys now search history based on typed prefix"
else
    print_yellow "Warning: inputrc not found at $DOTFILES_DIR/config/misc/inputrc"
fi

# ------------------------------------------------------------------------------
# Setup vim configuration
# ------------------------------------------------------------------------------
print_h2 "Configuring ~/.vimrc"

if [ -f "$DOTFILES_DIR/config/vim/vimrc" ]; then
    ln -sf "$DOTFILES_DIR/config/vim/vimrc" ~/.vimrc
    print_green "vimrc configured"
else
    print_yellow "Warning: vimrc not found at $DOTFILES_DIR/config/vim/vimrc"
fi

# ------------------------------------------------------------------------------
# Setup wget configuration
# ------------------------------------------------------------------------------
print_h2 "Configuring ~/.wgetrc"

if [ -f "$DOTFILES_DIR/config/misc/wgetrc" ]; then
    ln -sf "$DOTFILES_DIR/config/misc/wgetrc" ~/.wgetrc
    print_green "wgetrc configured"
else
    print_yellow "Warning: wgetrc not found at $DOTFILES_DIR/config/misc/wgetrc"
fi

# ------------------------------------------------------------------------------
# Setup FZF
# ------------------------------------------------------------------------------
if command_exists fzf; then
    print_h2 "Installing FZF key bindings and fuzzy completion"
    "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
    print_green "FZF installed"
fi

print_success "Done"
