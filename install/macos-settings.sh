#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# macOS system preferences automation
# These settings reflect the author's preferences - customize as needed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

# ------------------------------------------------------------------------------
# macOS System Preferences
# ------------------------------------------------------------------------------
print_h1 "Configuring macOS System Preferences"

# Close System Preferences to prevent conflicts
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# ------------------------------------------------------------------------------
# Dock Settings
# ------------------------------------------------------------------------------
print_h2 "Configuring Dock"

# Set Dock icon size (default: 45)
defaults write com.apple.dock tilesize -int 45

# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true

# Set Dock position (bottom, left, right)
defaults write com.apple.dock orientation -string "bottom"

# Group windows by application in Mission Control
defaults write com.apple.dock expose-group-apps -bool true

print_green "Dock settings configured"

# ------------------------------------------------------------------------------
# Finder Settings
# ------------------------------------------------------------------------------
print_h2 "Configuring Finder"

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show the ~/Library folder
chflags nohidden ~/Library

# Show the /Volumes folder
sudo chflags nohidden /Volumes 2>/dev/null || true

print_green "Finder settings configured"

# ------------------------------------------------------------------------------
# Screenshots Settings
# ------------------------------------------------------------------------------
print_h2 "Configuring Screenshots"

# Create screenshots directory
mkdir -p "${HOME}/Pictures/Screenshots"

# Set screenshots location
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"

print_green "Screenshots settings configured"

# ------------------------------------------------------------------------------
# Keyboard Settings
# ------------------------------------------------------------------------------
print_h2 "Configuring Keyboard"

# Set keyboard repeat rate (2 = very fast, 1-120)
defaults write NSGlobalDomain KeyRepeat -int 2

# Set initial key repeat delay (25 = short, 15-120)
defaults write NSGlobalDomain InitialKeyRepeat -int 25

print_green "Keyboard settings configured"

# ------------------------------------------------------------------------------
# Trackpad Settings
# ------------------------------------------------------------------------------
print_h2 "Configuring Trackpad"

# Enable tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

print_green "Trackpad settings configured"

# ------------------------------------------------------------------------------
# Mission Control Settings
# ------------------------------------------------------------------------------
print_h2 "Configuring Mission Control"

# Group windows by application
defaults write com.apple.dock expose-group-apps -bool true

print_green "Mission Control settings configured"

# ------------------------------------------------------------------------------
# Other macOS Settings
# ------------------------------------------------------------------------------
print_h2 "Configuring Other Settings"

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

print_green "Other settings configured"

# ------------------------------------------------------------------------------
# Restart affected applications
# ------------------------------------------------------------------------------
print_h2 "Restarting affected applications"

killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

print_green "Applications restarted"

echo ""
print_green "macOS settings configured successfully!"
print_yellow "Note: Some changes may require a logout/restart to take full effect"
