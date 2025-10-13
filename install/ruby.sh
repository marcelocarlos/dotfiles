#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# Setup Ruby environment with rbenv

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

# ------------------------------------------------------------------------------
# Ruby setup
# ------------------------------------------------------------------------------
print_h1 "Setting up Ruby"

if ! command_exists rbenv; then
    print_error "Error: rbenv is not installed. Install it via Homebrew first."
    exit 1
fi

GLOBAL_RUBY_VERSION="3.2.1"

# Check if Ruby version is installed
if ! rbenv versions | grep -q "$GLOBAL_RUBY_VERSION"; then
    print_h2 "Installing Ruby $GLOBAL_RUBY_VERSION"
    rbenv install "$GLOBAL_RUBY_VERSION"
    rbenv global "$GLOBAL_RUBY_VERSION"
    print_green "Ruby $GLOBAL_RUBY_VERSION installed"
else
    print_green "Ruby $GLOBAL_RUBY_VERSION already installed"
fi

# Initialize rbenv for current session
eval "$(rbenv init -)"

# Install bundler
if ! command_exists bundle; then
    print_h2 "Installing bundler"
    gem install bundler
    rbenv rehash
    print_green "Bundler installed"
else
    print_green "Bundler already installed"
fi

# Install rubocop
if ! gem list rubocop -i &> /dev/null; then
    print_h2 "Installing rubocop"
    gem install rubocop
    rbenv rehash
    print_green "Rubocop installed"
else
    print_green "Rubocop already installed"
fi

print_success "Done"
