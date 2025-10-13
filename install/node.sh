#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# Setup Node.js development environment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

# ------------------------------------------------------------------------------
# Node.js Development Setup
# ------------------------------------------------------------------------------
print_h1 "Setting up Node.js Development Environment"

# ------------------------------------------------------------------------------
# Validate Node.js Installation
# ------------------------------------------------------------------------------
print_h2 "Validating Node.js installation"

if ! command_exists node; then
    print_error "Error: Node.js is not installed"
    print_yellow "Install Node.js via Homebrew: brew install node"
    exit 1
fi

NODE_VERSION=$(node --version)
print_green "Node.js installed: $NODE_VERSION"

if ! command_exists npm; then
    print_error "Error: npm is not installed (should come with Node.js)"
    exit 1
fi

NPM_VERSION=$(npm --version)
print_green "npm installed: v$NPM_VERSION"

# ------------------------------------------------------------------------------
# Validate Yarn via Corepack
# ------------------------------------------------------------------------------
print_h2 "Validating Yarn (via Corepack)"

if command_exists yarn; then
    YARN_VERSION=$(yarn --version)
    print_green "Yarn available: v$YARN_VERSION (via Corepack)"
else
    print_yellow "Yarn not available (enable corepack to use yarn)"
fi

# ------------------------------------------------------------------------------
# Enable Corepack (for yarn/pnpm)
# ------------------------------------------------------------------------------
print_h2 "Configuring Corepack"

if command_exists corepack; then
    print_green "Corepack available (enables yarn/pnpm)"

    # Enable corepack if not already enabled
    if ! corepack enable 2>/dev/null; then
        print_yellow "Note: Run 'corepack enable' to activate yarn/pnpm support"
    else
        print_green "Corepack enabled"
    fi
else
    print_yellow "Corepack not available (comes with Node.js 16.10+)"
fi

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
echo ""
print_h1 "Node.js Development Environment Ready!"
echo ""
print_green "Installed tools:"
echo "  • node      - JavaScript runtime ($NODE_VERSION)"
echo "  • npm       - Package manager (v$NPM_VERSION)"
if command_exists yarn; then
    echo "  • yarn      - Fast package manager (v$(yarn --version))"
fi
echo ""
print_yellow "Quick start:"
echo "  npm install <package>       # Install packages with npm"
echo "  yarn add <package>          # Install packages with yarn (faster)"
echo "  npm init                    # Create a new project"
echo "  npx <command>               # Run packages without installing"
echo ""
print_success "Done"
