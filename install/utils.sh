#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlos/dotfiles
#
# Utility functions for install scripts

# ------------------------------------------------------------------------------
# Print functions (with emojis)
# ------------------------------------------------------------------------------
print_h1() {
    echo "$(tput bold)# ------------------------------------------------------------------------------$(tput sgr0)"
    echo "$(tput bold)# $* $(tput sgr0)"
    echo "$(tput bold)# ------------------------------------------------------------------------------$(tput sgr0)"
}

print_h2() {
    echo "$(tput bold)## $* $(tput sgr0)"
}

# Success messages (green, stdout)
print_success() {
    echo "$(tput setaf 2)✅ $* $(tput sgr0)"
}

print_green() {
    echo "$(tput setaf 2)$* $(tput sgr0)"
}

# Warning messages (yellow, stdout)
print_warning() {
    echo "$(tput setaf 3)⚠️  $* $(tput sgr0)"
}

print_yellow() {
    echo "$(tput setaf 3)$* $(tput sgr0)"
}

# Error messages (red, stderr)
print_error() {
    echo "$(tput setaf 1)❌ $* $(tput sgr0)" >&2
}

print_red() {
    echo "$(tput setaf 1)$* $(tput sgr0)" >&2
}

# Info messages (blue, stdout)
print_info() {
    echo "$(tput setaf 4)ℹ️  $* $(tput sgr0)"
}

print_blue() {
    echo "$(tput setaf 4)$* $(tput sgr0)"
}

# Section separator
print_separator() {
    echo ""
    echo "$(tput dim)────────────────────────────────────────────────────────────────────────────────$(tput sgr0)"
    echo ""
}

# Progress indicator
print_step() {
    echo "$(tput bold)$(tput setaf 6)▶ $* $(tput sgr0)"
}

# ------------------------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------------------------
# Check if a line exists in a file
# Usage: contains_line "text" "/path/to/file"
contains_line() {
    grep -qF "$1" "$2" 2>/dev/null
}

# Check if a command exists
# Usage: command_exists "command"
command_exists() {
    command -v "$1" &> /dev/null
}
