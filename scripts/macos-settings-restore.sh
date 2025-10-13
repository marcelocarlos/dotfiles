#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlos/dotfiles
#
# Restore macOS system preferences from backup

set -euo pipefail

# Check for backup file argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <backup-file.json>"
    echo ""
    echo "Available backups:"
    ls -1t "$HOME/.dotfiles/backups"/macos-settings-*.json 2>/dev/null || echo "  No backups found"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "Restoring macOS settings from: $BACKUP_FILE"
echo ""

# Close System Preferences to prevent conflicts
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# Helper function to read JSON values (requires jq or Python)
get_json_value() {
    local key="$1"
    if command -v jq &> /dev/null; then
        jq -r "$key // empty" "$BACKUP_FILE" 2>/dev/null
    else
        python3 -c "import json, sys; data=json.load(open('$BACKUP_FILE')); print(data$key)" 2>/dev/null || echo ""
    fi
}

# Helper function to apply setting if not null
apply_setting() {
    local domain="$1"
    local key="$2"
    local json_path="$3"
    local type="${4:-}"

    value=$(get_json_value "$json_path")

    if [ -n "$value" ] && [ "$value" != "null" ]; then
        case "$type" in
            int)
                defaults write "$domain" "$key" -int "$value"
                ;;
            bool)
                # Convert 1/0 to true/false
                if [ "$value" = "1" ] || [ "$value" = "true" ]; then
                    defaults write "$domain" "$key" -bool true
                else
                    defaults write "$domain" "$key" -bool false
                fi
                ;;
            string)
                defaults write "$domain" "$key" -string "$value"
                ;;
            *)
                defaults write "$domain" "$key" "$value"
                ;;
        esac
        echo "  ✓ Applied $domain $key = $value"
    fi
}

# Restore Dock settings
echo "Restoring Dock settings..."
apply_setting "com.apple.dock" "tilesize" ".settings.dock.tilesize" "int"
apply_setting "com.apple.dock" "autohide" ".settings.dock.autohide" "bool"
apply_setting "com.apple.dock" "orientation" ".settings.dock.orientation" "string"
apply_setting "com.apple.dock" "show-recents" ".settings.dock[\"show-recents\"]" "bool"
apply_setting "com.apple.dock" "expose-group-apps" ".settings.dock[\"expose-group-apps\"]" "bool"
apply_setting "com.apple.dock" "mru-spaces" ".settings.dock[\"mru-spaces\"]" "bool"

# Restore Finder settings
echo "Restoring Finder settings..."
apply_setting "com.apple.finder" "ShowStatusBar" ".settings.finder.ShowStatusBar" "bool"
apply_setting "com.apple.finder" "ShowPathbar" ".settings.finder.ShowPathbar" "bool"
apply_setting "com.apple.finder" "AppleShowAllFiles" ".settings.finder.AppleShowAllFiles" "bool"
apply_setting "com.apple.finder" "_FXShowPosixPathInTitle" ".settings.finder._FXShowPosixPathInTitle" "bool"

# Restore Keyboard settings
echo "Restoring Keyboard settings..."
apply_setting "NSGlobalDomain" "KeyRepeat" ".settings.keyboard.KeyRepeat" "int"
apply_setting "NSGlobalDomain" "InitialKeyRepeat" ".settings.keyboard.InitialKeyRepeat" "int"
apply_setting "NSGlobalDomain" "ApplePressAndHoldEnabled" ".settings.keyboard.ApplePressAndHoldEnabled" "bool"

# Restore Trackpad settings
echo "Restoring Trackpad settings..."
apply_setting "com.apple.AppleMultitouchTrackpad" "Clicking" ".settings.trackpad.Clicking" "bool"
apply_setting "com.apple.AppleMultitouchTrackpad" "TrackpadThreeFingerDrag" ".settings.trackpad.TrackpadThreeFingerDrag" "bool"

# Restore Global settings
echo "Restoring Global settings..."
apply_setting "NSGlobalDomain" "NSAutomaticCapitalizationEnabled" ".settings.global.NSAutomaticCapitalizationEnabled" "bool"
apply_setting "NSGlobalDomain" "NSAutomaticDashSubstitutionEnabled" ".settings.global.NSAutomaticDashSubstitutionEnabled" "bool"
apply_setting "NSGlobalDomain" "NSAutomaticPeriodSubstitutionEnabled" ".settings.global.NSAutomaticPeriodSubstitutionEnabled" "bool"
apply_setting "NSGlobalDomain" "NSAutomaticQuoteSubstitutionEnabled" ".settings.global.NSAutomaticQuoteSubstitutionEnabled" "bool"
apply_setting "NSGlobalDomain" "NSAutomaticSpellingCorrectionEnabled" ".settings.global.NSAutomaticSpellingCorrectionEnabled" "bool"
apply_setting "NSGlobalDomain" "NSDocumentSaveNewDocumentsToCloud" ".settings.global.NSDocumentSaveNewDocumentsToCloud" "bool"

# Restart affected applications
echo ""
echo "Restarting affected applications..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo ""
echo "✓ Settings restored successfully!"
echo "Note: Some changes may require a logout/restart to take full effect"
