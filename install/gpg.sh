#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlos/dotfiles
#
# Setup GPG with git commit signing support

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

# ------------------------------------------------------------------------------
# GPG Installation Validation
# ------------------------------------------------------------------------------
print_h1 "Setting up GPG for Git Commit Signing"

print_h2 "Validating GPG installation"

if ! command_exists gpg; then
    print_error "Error: GPG (gnupg) is not installed"
    print_yellow "Install via Homebrew: brew install gnupg"
    exit 1
fi

GPG_VERSION=$(gpg --version | head -1)
print_green "GPG installed: $GPG_VERSION"

if ! command_exists pinentry-mac; then
    print_yellow "Warning: pinentry-mac not installed"
    print_yellow "Install via Homebrew: brew install pinentry-mac"
    print_yellow "This provides a GUI for entering GPG passphrases on macOS"
else
    print_green "pinentry-mac installed"
fi

# ------------------------------------------------------------------------------
# Configure pinentry for macOS
# ------------------------------------------------------------------------------
print_h2 "Configuring GPG pinentry"

GPG_CONF_DIR="$HOME/.gnupg"
GPG_AGENT_CONF="$GPG_CONF_DIR/gpg-agent.conf"

mkdir -p "$GPG_CONF_DIR"
chmod 700 "$GPG_CONF_DIR"

# Configure pinentry-mac if available
if command_exists pinentry-mac; then
    PINENTRY_PATH=$(command -v pinentry-mac)

    if [ -f "$GPG_AGENT_CONF" ]; then
        # Check if pinentry-program is already configured
        if grep -q "^pinentry-program" "$GPG_AGENT_CONF"; then
            print_green "pinentry already configured in $GPG_AGENT_CONF"
        else
            echo "pinentry-program $PINENTRY_PATH" >> "$GPG_AGENT_CONF"
            print_green "Added pinentry-program to $GPG_AGENT_CONF"
        fi
    else
        echo "pinentry-program $PINENTRY_PATH" > "$GPG_AGENT_CONF"
        print_green "Created $GPG_AGENT_CONF with pinentry configuration"
    fi

    # Reload GPG agent
    gpg-connect-agent reloadagent /bye >/dev/null 2>&1 || true
fi

# ------------------------------------------------------------------------------
# Check for existing GPG keys
# ------------------------------------------------------------------------------
print_h2 "Checking for GPG keys"

# Check local keyring
LOCAL_KEYS=$(gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep -c "^sec" || true)
if [ -z "$LOCAL_KEYS" ]; then
    LOCAL_KEYS=0
fi

# Check for YubiKey/hardware tokens
YUBIKEY_DETECTED=false
if gpg --card-status 2>/dev/null | grep -q "Signature key"; then
    # Check if Signature key has actual fingerprint (not "none" or "[none]")
    if gpg --card-status 2>/dev/null | grep "^Signature key" | grep -qv "none"; then
        YUBIKEY_DETECTED=true
        print_green "YubiKey or hardware token with keys detected"
    fi
fi

if [ "$LOCAL_KEYS" -gt 0 ] || [ "$YUBIKEY_DETECTED" = true ]; then
    echo ""
    print_green "Found existing GPG keys:"
    echo ""

    if [ "$LOCAL_KEYS" -gt 0 ]; then
        print_yellow "Local keys:"
        gpg --list-secret-keys --keyid-format=long
        echo ""
    fi

    if [ "$YUBIKEY_DETECTED" = true ]; then
        print_yellow "Hardware token keys:"
        gpg --card-status 2>/dev/null | grep -E "^(Signature|Encryption|Authentication) key"
        echo ""
        print_yellow "Note: For git commit signing, use the Signature key"
        echo ""
    fi

    # Prompt user to select a key
    echo ""
    print_yellow "Enter the GPG key ID you want to use for git signing:"
    print_yellow "(Use the last 16 characters of the key, e.g., 7D924F5431DA7463)"
    print_yellow "(You can copy with spaces - they'll be removed automatically)"
    read -r -p "> " SELECTED_KEY

    if [ -z "$SELECTED_KEY" ]; then
        print_yellow "No key selected. Skipping git configuration."
        exit 0
    fi

    # Remove spaces from the key ID
    SELECTED_KEY=$(echo "$SELECTED_KEY" | tr -d ' ')

    # If using YubiKey, check if we need to fetch the public key stub
    if [ "$YUBIKEY_DETECTED" = true ]; then
        if ! gpg --list-secret-keys "$SELECTED_KEY" &>/dev/null; then
            print_yellow "Importing public key stub from hardware token..."
            if gpg --card-status > /dev/null 2>&1; then
                # Try to fetch the key from the card
                gpg --card-edit <<EOF >/dev/null 2>&1 || true
fetch
quit
EOF
            fi
        fi
    fi

    # Verify the key exists (after potential import)
    if ! gpg --list-secret-keys "$SELECTED_KEY" &>/dev/null; then
        # For YubiKey, might still work even if not in local keyring
        if [ "$YUBIKEY_DETECTED" = true ]; then
            # Check if it matches a key on the card (remove spaces from card status for comparison)
            CARD_KEYS=$(gpg --card-status 2>/dev/null | grep -E "^(Signature|Encryption|Authentication) key" | tr -d ' ')
            if ! echo "$CARD_KEYS" | grep -q "$SELECTED_KEY"; then
                print_error "Error: Key $SELECTED_KEY not found on hardware token"
                print_yellow "Available keys on card:"
                gpg --card-status 2>/dev/null | grep -E "^(Signature|Encryption|Authentication) key"
                exit 1
            fi
            print_yellow "Note: Key is on hardware token but not in local keyring"
            print_yellow "Git will use the hardware token for signing"
        else
            print_error "Error: Key $SELECTED_KEY not found"
            exit 1
        fi
    fi

    # Configure git
    echo ""
    print_yellow "Configure git to use key: $SELECTED_KEY? (y/n)"
    read -r -p "> " CONFIRM

    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        git config --global user.signingkey "$SELECTED_KEY"
        git config --global commit.gpgsign true
        git config --global gpg.program gpg

        print_green "Git configured for GPG signing!"
        echo ""
        print_green "Configuration applied:"
        echo "  user.signingkey = $SELECTED_KEY"
        echo "  commit.gpgsign = true"
        echo "  gpg.program = gpg"

        # Show GitHub instructions
        echo ""
        print_h1 "Add GPG Key to GitHub"
        echo ""
        print_yellow "To enable verified commits on GitHub:"
        echo ""
        echo "1. Copy your public GPG key:"
        echo ""
        echo "   gpg --armor --export $SELECTED_KEY"
        echo ""
        echo "2. Go to: https://github.com/settings/keys"
        echo "3. Click 'New GPG key'"
        echo "4. Paste your key and save"
        echo "5. Your commits will now show as 'Verified' on GitHub"
        echo ""
        print_yellow "Export your public key now? (y/n)"
        read -r -p "> " EXPORT_KEY

        if [[ "$EXPORT_KEY" =~ ^[Yy]$ ]]; then
            echo ""
            print_green "Your public GPG key:"
            echo ""
            gpg --armor --export "$SELECTED_KEY"
            echo ""
        fi
    else
        print_yellow "Skipped git configuration"
    fi
else
    # No keys found - offer to create one
    echo ""
    print_yellow "No GPG keys found (local or hardware token)"
    echo ""
    print_yellow "Would you like to generate a new GPG key? (y/n)"
    read -r -p "> " CREATE_KEY

    if [[ "$CREATE_KEY" =~ ^[Yy]$ ]]; then
        # Get user info from git config or prompt
        GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
        GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

        if [ -z "$GIT_NAME" ]; then
            print_yellow "Enter your name:"
            read -r -p "> " GIT_NAME
        else
            print_yellow "Name (from git config): $GIT_NAME"
            print_yellow "Press Enter to use this, or type a different name:"
            read -r -p "> " INPUT_NAME
            if [ -n "$INPUT_NAME" ]; then
                GIT_NAME="$INPUT_NAME"
            fi
        fi

        if [ -z "$GIT_EMAIL" ]; then
            print_yellow "Enter your email:"
            read -r -p "> " GIT_EMAIL
        else
            print_yellow "Email (from git config): $GIT_EMAIL"
            print_yellow "Press Enter to use this, or type a different email:"
            read -r -p "> " INPUT_EMAIL
            if [ -n "$INPUT_EMAIL" ]; then
                GIT_EMAIL="$INPUT_EMAIL"
            fi
        fi

        echo ""
        print_yellow "Generating GPG key for: $GIT_NAME <$GIT_EMAIL>"
        print_yellow "Follow the prompts to select key type and set a passphrase"
        echo ""

        # Use batch mode for non-interactive key generation
        cat > /tmp/gpg-keygen-batch <<EOF
%echo Generating GPG key
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $GIT_NAME
Name-Email: $GIT_EMAIL
Expire-Date: 0
%no-protection
%commit
%echo Done
EOF

        print_yellow "Generating key (this may take a moment)..."
        if gpg --batch --generate-key /tmp/gpg-keygen-batch 2>&1; then
            rm -f /tmp/gpg-keygen-batch

            # Get the newly created key ID
            NEW_KEY=$(gpg --list-secret-keys --keyid-format=long "$GIT_EMAIL" 2>/dev/null | grep "^sec" | head -1 | awk '{print $2}' | cut -d'/' -f2)

            if [ -z "$NEW_KEY" ]; then
                print_error "Error: Failed to find newly created key"
                exit 1
            fi

            print_green "GPG key created: $NEW_KEY"
            echo ""
            print_yellow "IMPORTANT: You should add a passphrase to your key for security:"
            echo "  gpg --edit-key $NEW_KEY"
            echo "  Then type 'passwd' to set a passphrase"
            echo ""

            # Configure git
            print_yellow "Configure git to use this key? (y/n)"
            read -r -p "> " CONFIRM_NEW

            if [[ "$CONFIRM_NEW" =~ ^[Yy]$ ]]; then
                git config --global user.signingkey "$NEW_KEY"
                git config --global commit.gpgsign true
                git config --global gpg.program gpg

                print_green "Git configured for GPG signing!"
                echo ""
                print_green "Configuration applied:"
                echo "  user.signingkey = $NEW_KEY"
                echo "  commit.gpgsign = true"
                echo "  gpg.program = gpg"

                # Show GitHub instructions
                echo ""
                print_h1 "Add GPG Key to GitHub"
                echo ""
                print_yellow "To enable verified commits on GitHub:"
                echo ""
                echo "1. Copy your public GPG key:"
                echo ""
                echo "   gpg --armor --export $NEW_KEY"
                echo ""
                echo "2. Go to: https://github.com/settings/keys"
                echo "3. Click 'New GPG key'"
                echo "4. Paste your key and save"
                echo "5. Your commits will now show as 'Verified' on GitHub"
                echo ""
                print_yellow "Export your public key now? (y/n)"
                read -r -p "> " EXPORT_NEW_KEY

                if [[ "$EXPORT_NEW_KEY" =~ ^[Yy]$ ]]; then
                    echo ""
                    print_green "Your public GPG key:"
                    echo ""
                    gpg --armor --export "$NEW_KEY"
                    echo ""
                fi
            else
                print_yellow "Skipped git configuration"
                print_yellow "To configure later, run:"
                echo "  git config --global user.signingkey $NEW_KEY"
                echo "  git config --global commit.gpgsign true"
            fi
        else
            rm -f /tmp/gpg-keygen-batch
            print_red "Key generation failed"
            exit 1
        fi
    else
        print_yellow "Skipped key generation"
        echo ""
        print_yellow "To create a key later, run: gpg --full-generate-key"
        print_yellow "Then configure git with:"
        echo "  git config --global user.signingkey <KEY_ID>"
        echo "  git config --global commit.gpgsign true"
    fi
fi

echo ""
print_success "Done"
