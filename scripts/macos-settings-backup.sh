#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# Backup current macOS system preferences

set -euo pipefail

# Setup backup directory
BACKUP_DIR="$HOME/.dotfiles/backups"
mkdir -p "$BACKUP_DIR"

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/macos-settings-$TIMESTAMP.json"

echo "Backing up macOS settings to: $BACKUP_FILE"

# Create JSON backup
cat > "$BACKUP_FILE" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "hostname": "$(hostname)",
  "macos_version": "$(sw_vers -productVersion)",
  "settings": {
    "dock": {
      "tilesize": $(defaults read com.apple.dock tilesize 2>/dev/null || echo "null"),
      "autohide": $(defaults read com.apple.dock autohide 2>/dev/null || echo "null"),
      "orientation": "$(defaults read com.apple.dock orientation 2>/dev/null || echo "bottom")",
      "show-recents": $(defaults read com.apple.dock show-recents 2>/dev/null || echo "null"),
      "expose-group-apps": $(defaults read com.apple.dock expose-group-apps 2>/dev/null || echo "null"),
      "mru-spaces": $(defaults read com.apple.dock mru-spaces 2>/dev/null || echo "null")
    },
    "finder": {
      "ShowStatusBar": $(defaults read com.apple.finder ShowStatusBar 2>/dev/null || echo "null"),
      "ShowPathbar": $(defaults read com.apple.finder ShowPathbar 2>/dev/null || echo "null"),
      "AppleShowAllFiles": $(defaults read com.apple.finder AppleShowAllFiles 2>/dev/null || echo "null"),
      "_FXShowPosixPathInTitle": $(defaults read com.apple.finder _FXShowPosixPathInTitle 2>/dev/null || echo "null")
    },
    "keyboard": {
      "KeyRepeat": $(defaults read NSGlobalDomain KeyRepeat 2>/dev/null || echo "null"),
      "InitialKeyRepeat": $(defaults read NSGlobalDomain InitialKeyRepeat 2>/dev/null || echo "null"),
      "ApplePressAndHoldEnabled": $(defaults read NSGlobalDomain ApplePressAndHoldEnabled 2>/dev/null || echo "null")
    },
    "trackpad": {
      "Clicking": $(defaults read com.apple.AppleMultitouchTrackpad Clicking 2>/dev/null || echo "null"),
      "TrackpadThreeFingerDrag": $(defaults read com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag 2>/dev/null || echo "null")
    },
    "global": {
      "NSAutomaticCapitalizationEnabled": $(defaults read NSGlobalDomain NSAutomaticCapitalizationEnabled 2>/dev/null || echo "null"),
      "NSAutomaticDashSubstitutionEnabled": $(defaults read NSGlobalDomain NSAutomaticDashSubstitutionEnabled 2>/dev/null || echo "null"),
      "NSAutomaticPeriodSubstitutionEnabled": $(defaults read NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled 2>/dev/null || echo "null"),
      "NSAutomaticQuoteSubstitutionEnabled": $(defaults read NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled 2>/dev/null || echo "null"),
      "NSAutomaticSpellingCorrectionEnabled": $(defaults read NSGlobalDomain NSAutomaticSpellingCorrectionEnabled 2>/dev/null || echo "null"),
      "NSDocumentSaveNewDocumentsToCloud": $(defaults read NSGlobalDomain NSDocumentSaveNewDocumentsToCloud 2>/dev/null || echo "null")
    }
  }
}
EOF

echo "✓ Backup completed successfully"
echo ""
echo "To restore these settings later, run:"
echo "  ./scripts/macos-settings-restore.sh $BACKUP_FILE"
