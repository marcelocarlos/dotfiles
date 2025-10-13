#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlos/dotfiles
#
# Setup git hooks for secret scanning

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BLUE}Setting up Git Hooks for Secret Scanning${RESET}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

# ------------------------------------------------------------------------------
# Install git-secrets
# ------------------------------------------------------------------------------
if ! command -v git-secrets &> /dev/null; then
    echo -e "${YELLOW}▶ git-secrets not found, installing...${RESET}"
    if command -v brew &> /dev/null; then
        brew install git-secrets
        echo -e "${GREEN}✓ git-secrets installed${RESET}\n"
    else
        echo -e "${RED}✗ Error: Homebrew not found. Install git-secrets manually:${RESET}"
        echo -e "  ${BLUE}brew install git-secrets${RESET}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ git-secrets is already installed${RESET}\n"
fi

# ------------------------------------------------------------------------------
# Install hooks in this repository
# ------------------------------------------------------------------------------
echo -e "${YELLOW}▶ Installing git-secrets hooks...${RESET}"
cd "$DOTFILES_DIR"

# Install pre-commit and prepare-commit-msg hooks
git secrets --install --force

echo -e "${GREEN}✓ Git hooks installed${RESET}\n"

# ------------------------------------------------------------------------------
# Register AWS patterns (built-in)
# ------------------------------------------------------------------------------
echo -e "${YELLOW}▶ Registering AWS secret patterns...${RESET}"
git secrets --register-aws

echo -e "${GREEN}✓ AWS patterns registered${RESET}\n"

# ------------------------------------------------------------------------------
# Add custom patterns
# ------------------------------------------------------------------------------
echo -e "${YELLOW}▶ Adding custom secret patterns...${RESET}"

# Generic patterns for common secrets
git secrets --add 'password\s*=\s*["\047][^\s]+["\047]' 2>/dev/null || true
git secrets --add 'api[_-]?key\s*=\s*["\047][^\s]+["\047]' 2>/dev/null || true
git secrets --add 'api[_-]?secret\s*=\s*["\047][^\s]+["\047]' 2>/dev/null || true
git secrets --add 'token\s*=\s*["\047][^\s]+["\047]' 2>/dev/null || true
git secrets --add 'private[_-]?key\s*=\s*["\047][^\s]+["\047]' 2>/dev/null || true

# SSH private keys
git secrets --add '-----BEGIN\s+(RSA|DSA|EC|OPENSSH)\s+PRIVATE\s+KEY-----' 2>/dev/null || true

# Generic API tokens and keys (longer sequences)
git secrets --add '["\047][0-9a-zA-Z]{32,}["\047]' 2>/dev/null || true

echo -e "${GREEN}✓ Custom patterns added${RESET}\n"

# ------------------------------------------------------------------------------
# Add allowed patterns (to reduce false positives)
# ------------------------------------------------------------------------------
echo -e "${YELLOW}▶ Configuring allowed patterns...${RESET}"

# Allow example/placeholder values
git secrets --add --allowed 'example\.com' 2>/dev/null || true
git secrets --add --allowed 'EXAMPLE_KEY' 2>/dev/null || true
git secrets --add --allowed 'YOUR_.*_HERE' 2>/dev/null || true
git secrets --add --allowed 'REPLACE_WITH_' 2>/dev/null || true
git secrets --add --allowed 'password.*example' 2>/dev/null || true
git secrets --add --allowed 'api[_-]?key.*example' 2>/dev/null || true

# Allow macOS defaults/settings keys (NSAutomaticCapitalizationEnabled, etc.)
git secrets --add --allowed 'NS[A-Z][a-zA-Z]+' 2>/dev/null || true
git secrets --add --allowed 'defaults (read|write)' 2>/dev/null || true
git secrets --add --allowed 'NSGlobalDomain' 2>/dev/null || true

# Allow configuration variables in shell scripts
git secrets --add --allowed '\$\{[A-Z_]+\}' 2>/dev/null || true
git secrets --add --allowed 'INSTALL_[A-Z_]+' 2>/dev/null || true
git secrets --add --allowed 'ENABLE_[A-Z_]+' 2>/dev/null || true
git secrets --add --allowed 'LOAD_[A-Z_]+' 2>/dev/null || true

echo -e "${GREEN}✓ Allowed patterns configured${RESET}\n"

# ------------------------------------------------------------------------------
# Scan existing repository
# ------------------------------------------------------------------------------
echo -e "${YELLOW}▶ Scanning existing repository for secrets...${RESET}\n"

if git secrets --scan; then
    echo -e "\n${GREEN}✓ No secrets found in current files${RESET}\n"
else
    echo -e "\n${RED}✗ Secrets detected in repository!${RESET}"
    echo -e "${YELLOW}Review the output above and remove any sensitive data.${RESET}\n"
    exit 1
fi

# ------------------------------------------------------------------------------
# Scan commit history
# ------------------------------------------------------------------------------
echo -e "${YELLOW}▶ Scanning commit history for secrets...${RESET}"
echo -e "${BLUE}This may take a moment...${RESET}\n"

if git secrets --scan-history; then
    echo -e "\n${GREEN}✓ No secrets found in git history${RESET}\n"
else
    echo -e "\n${RED}✗ Secrets detected in git history!${RESET}"
    echo -e "${YELLOW}Consider using git-filter-repo or BFG Repo-Cleaner to remove them.${RESET}\n"
    echo -e "${BLUE}Continue anyway? The pre-commit hook will prevent new secrets.${RESET}\n"
fi

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}✓ Git hooks setup complete!${RESET}\n"

echo -e "${BLUE}What's configured:${RESET}"
echo -e "  • Pre-commit hook - Scans files before commit"
echo -e "  • AWS secret patterns - Detects AWS keys and tokens"
echo -e "  • Custom patterns - Detects passwords, API keys, private keys"
echo -e "  • Allowed patterns - Reduces false positives\n"

echo -e "${BLUE}Usage:${RESET}"
echo -e "  • Commits with secrets will be blocked automatically"
echo -e "  • To scan files manually: ${YELLOW}git secrets --scan${RESET}"
echo -e "  • To scan history: ${YELLOW}git secrets --scan-history${RESET}"
echo -e "  • To list patterns: ${YELLOW}git secrets --list${RESET}\n"

echo -e "${YELLOW}Note: To skip the hook (not recommended):${RESET}"
echo -e "  git commit --no-verify\n"
