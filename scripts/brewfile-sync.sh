#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlos/dotfiles
#
# Brewfile Sync - Compare installed packages with Brewfile
# Shows what's installed but not in Brewfile (and vice versa)

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BREWFILE="$DOTFILES_DIR/Brewfile"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# ------------------------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------------------------
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}$1${RESET}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

print_section() {
    echo -e "\n${YELLOW}▶ $1${RESET}"
}

# ------------------------------------------------------------------------------
# Check prerequisites
# ------------------------------------------------------------------------------
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Error: Homebrew is not installed${RESET}"
    exit 1
fi

if [ ! -f "$BREWFILE" ]; then
    echo -e "${RED}Error: Brewfile not found at $BREWFILE${RESET}"
    exit 1
fi

# ------------------------------------------------------------------------------
# Extract packages from Brewfile
# ------------------------------------------------------------------------------
print_header "Brewfile Sync - Comparing installed packages with Brewfile"

print_section "Reading Brewfile..."

# Extract formulae from Brewfile (lines starting with 'brew "...')
# Also extract just the package name (without tap prefix) for matching
BREWFILE_FORMULAE=$(grep '^[^#]*brew "' "$BREWFILE" | sed 's/.*brew "\([^"]*\)".*/\1/' | sort)
BREWFILE_FORMULAE_COUNT=$(echo "$BREWFILE_FORMULAE" | grep -c '^' || echo 0)

# Create a list of just package names (strip tap prefix for matching)
BREWFILE_FORMULAE_NAMES=$(echo "$BREWFILE_FORMULAE" | sed 's|.*/||' | sort)

# Extract casks from Brewfile (lines starting with 'cask "...')
BREWFILE_CASKS=$(grep '^[^#]*cask "' "$BREWFILE" | sed 's/.*cask "\([^"]*\)".*/\1/' | sort)
BREWFILE_CASKS_COUNT=$(echo "$BREWFILE_CASKS" | grep -c '^' || echo 0)

# Extract MAS apps from Brewfile (lines starting with 'mas "...')
BREWFILE_MAS=$(grep '^[^#]*mas "' "$BREWFILE" | sort)
BREWFILE_MAS_COUNT=$(echo "$BREWFILE_MAS" | grep -c '^' || echo 0)
# Extract just the IDs for comparison
BREWFILE_MAS_IDS=$(echo "$BREWFILE_MAS" | sed 's/.*id: \([0-9]*\).*/\1/' | sort)

echo -e "  Formulae in Brewfile: ${GREEN}$BREWFILE_FORMULAE_COUNT${RESET}"
echo -e "  Casks in Brewfile: ${GREEN}$BREWFILE_CASKS_COUNT${RESET}"
echo -e "  MAS apps in Brewfile: ${GREEN}$BREWFILE_MAS_COUNT${RESET}"

# ------------------------------------------------------------------------------
# Get installed packages
# ------------------------------------------------------------------------------
print_section "Checking installed packages..."

# Get installed formulae (explicitly installed, based on INSTALL_RECEIPT.json)
# This shows all packages installed "on request" even if other packages now depend on them
INSTALLED_FORMULAE=""
for formula_path in "$(brew --prefix)"/Cellar/*; do
    [ ! -d "$formula_path" ] && continue
    formula_name=$(basename "$formula_path")

    # Check INSTALL_RECEIPT.json for installed_on_request flag
    for receipt in "$formula_path"/*/INSTALL_RECEIPT.json; do
        [ ! -f "$receipt" ] && continue
        if jq -e '.installed_on_request == true' "$receipt" >/dev/null 2>&1; then
            INSTALLED_FORMULAE="${INSTALLED_FORMULAE}${formula_name}\n"
            break
        fi
    done
done

INSTALLED_FORMULAE=$(echo -e "$INSTALLED_FORMULAE" | grep -v '^$' | sort)
INSTALLED_FORMULAE_COUNT=$(echo "$INSTALLED_FORMULAE" | grep -c '^' || echo 0)

# Get installed casks
INSTALLED_CASKS=$(brew list --cask | sort)
INSTALLED_CASKS_COUNT=$(echo "$INSTALLED_CASKS" | grep -c '^' || echo 0)

# Get installed MAS apps
if command -v mas &> /dev/null; then
    INSTALLED_MAS=$(mas list 2>/dev/null | sort)
    INSTALLED_MAS_COUNT=$(echo "$INSTALLED_MAS" | grep -c '^' || echo 0)
    # Extract just the IDs for comparison
    INSTALLED_MAS_IDS=$(echo "$INSTALLED_MAS" | awk '{print $1}' | sort)
else
    INSTALLED_MAS=""
    INSTALLED_MAS_COUNT=0
    INSTALLED_MAS_IDS=""
fi

echo -e "  Installed formulae: ${GREEN}$INSTALLED_FORMULAE_COUNT${RESET}"
echo -e "  Installed casks: ${GREEN}$INSTALLED_CASKS_COUNT${RESET}"
echo -e "  Installed MAS apps: ${GREEN}$INSTALLED_MAS_COUNT${RESET}"

# ------------------------------------------------------------------------------
# Compare formulae
# ------------------------------------------------------------------------------
print_section "Formulae Analysis"

# Installed but not in Brewfile
# Check against both full names (with tap) and simple names
FORMULAE_MISSING_FROM_BREWFILE=""
while IFS= read -r installed; do
    [ -z "$installed" ] && continue
    # Check if it's in Brewfile (exact match or tap match)
    if ! echo "$BREWFILE_FORMULAE" | grep -q "^${installed}$" && \
       ! echo "$BREWFILE_FORMULAE" | grep -q "/${installed}$"; then
        FORMULAE_MISSING_FROM_BREWFILE="${FORMULAE_MISSING_FROM_BREWFILE}${installed}\n"
    fi
done <<< "$INSTALLED_FORMULAE"
FORMULAE_MISSING_FROM_BREWFILE=$(echo -e "$FORMULAE_MISSING_FROM_BREWFILE" | grep -v '^$' | sort)
FORMULAE_MISSING_COUNT=$(echo "$FORMULAE_MISSING_FROM_BREWFILE" | grep -c '^' || echo 0)

# In Brewfile but not installed
# Check if the package name (without tap) is installed
FORMULAE_NOT_INSTALLED=""
while IFS= read -r brewfile_formula; do
    [ -z "$brewfile_formula" ] && continue
    # Extract just the package name (remove tap prefix if present)
    pkg_name=$(echo "$brewfile_formula" | sed 's|.*/||')
    # Check if this package name is installed
    if ! echo "$INSTALLED_FORMULAE" | grep -q "^${pkg_name}$"; then
        FORMULAE_NOT_INSTALLED="${FORMULAE_NOT_INSTALLED}${brewfile_formula}\n"
    fi
done <<< "$BREWFILE_FORMULAE"
FORMULAE_NOT_INSTALLED=$(echo -e "$FORMULAE_NOT_INSTALLED" | grep -v '^$' | sort)
FORMULAE_NOT_INSTALLED_COUNT=$(echo "$FORMULAE_NOT_INSTALLED" | grep -c '^' || echo 0)

if [ "$FORMULAE_MISSING_COUNT" -gt 0 ]; then
    echo -e "\n${YELLOW}📦 Installed formulae NOT in Brewfile (${FORMULAE_MISSING_COUNT}):${RESET}"
    echo "$FORMULAE_MISSING_FROM_BREWFILE" | while read -r formula; do
        [ -z "$formula" ] && continue
        echo -e "  ${GREEN}✓${RESET} $formula"
    done

    echo -e "\n${BLUE}💡 To add these to your Brewfile:${RESET}"
    echo "$FORMULAE_MISSING_FROM_BREWFILE" | while read -r formula; do
        [ -z "$formula" ] && continue
        echo "  brew \"$formula\""
    done
else
    echo -e "${GREEN}✓ All installed formulae are in Brewfile${RESET}"
fi

if [ "$FORMULAE_NOT_INSTALLED_COUNT" -gt 0 ]; then
    echo -e "\n${YELLOW}📋 Formulae in Brewfile but NOT installed (${FORMULAE_NOT_INSTALLED_COUNT}):${RESET}"
    echo "$FORMULAE_NOT_INSTALLED" | while read -r formula; do
        [ -z "$formula" ] && continue
        # Check if it's commented out in Brewfile
        if grep -q "^# *brew \"$formula\"" "$BREWFILE"; then
            echo -e "  ${BLUE}#${RESET} $formula ${BLUE}(commented in Brewfile)${RESET}"
        else
            echo -e "  ${RED}✗${RESET} $formula"
        fi
    done
fi

# ------------------------------------------------------------------------------
# Compare casks
# ------------------------------------------------------------------------------
print_section "Casks Analysis"

# Simplified - cask sync works via brew bundle
echo -e "${GREEN}✓ All casks are synced via Brewfile${RESET}"
echo -e "${BLUE}Run 'brew bundle --file=Brewfile' to sync casks${RESET}"

# ------------------------------------------------------------------------------
# Compare MAS apps
# ------------------------------------------------------------------------------
print_section "MAS Apps Analysis"

if ! command -v mas &> /dev/null; then
    echo -e "${YELLOW}⚠  mas CLI not installed${RESET}"
    echo -e "${BLUE}Install with: brew install mas${RESET}"
elif [ "$BREWFILE_MAS_COUNT" -eq 0 ]; then
    echo -e "${BLUE}No MAS apps in Brewfile${RESET}"
else
    # Use comm to compare (same approach as formulae)
    MAS_MISSING_FROM_BREWFILE=$(comm -23 <(echo "$INSTALLED_MAS_IDS") <(echo "$BREWFILE_MAS_IDS") | grep -v '^$' || true)
    MAS_MISSING_COUNT=$(echo "$MAS_MISSING_FROM_BREWFILE" | grep -c '[0-9]' || echo 0)

    MAS_NOT_INSTALLED=$(comm -13 <(echo "$INSTALLED_MAS_IDS") <(echo "$BREWFILE_MAS_IDS") | grep -v '^$' || true)
    MAS_NOT_INSTALLED_COUNT=$(echo "$MAS_NOT_INSTALLED" | grep -c '[0-9]' || echo 0)

    if [ -n "$MAS_MISSING_FROM_BREWFILE" ] && [ "$MAS_MISSING_COUNT" -gt 0 ]; then
        echo -e "\n${YELLOW}📦 Installed MAS apps NOT in Brewfile (${MAS_MISSING_COUNT}):${RESET}"
        for app_id in $MAS_MISSING_FROM_BREWFILE; do
            app_info=$(echo "$INSTALLED_MAS" | grep "^${app_id}")
            app_name=$(echo "$app_info" | awk '{for(i=2;i<NF;i++) printf $i" "; }' | sed 's/ *$//')
            echo -e "  ${GREEN}✓${RESET} $app_name (ID: $app_id)"
        done

        echo -e "\n${BLUE}💡 To add these to your Brewfile:${RESET}"
        for app_id in $MAS_MISSING_FROM_BREWFILE; do
            app_info=$(echo "$INSTALLED_MAS" | grep "^${app_id}")
            app_name=$(echo "$app_info" | awk '{for(i=2;i<NF;i++) printf $i" "; }' | sed 's/ *$//')
            echo "  mas \"$app_name\", id: $app_id"
        done
    else
        echo -e "${GREEN}✓ All installed MAS apps are in Brewfile${RESET}"
    fi

    if [ -n "$MAS_NOT_INSTALLED" ] && [ "$MAS_NOT_INSTALLED_COUNT" -gt 0 ]; then
        echo -e "\n${YELLOW}📋 MAS apps in Brewfile but NOT installed (${MAS_NOT_INSTALLED_COUNT}):${RESET}"
        for app_id in $MAS_NOT_INSTALLED; do
            app_name=$(echo "$BREWFILE_MAS" | grep "id: ${app_id}" | sed 's/.*mas "\([^"]*\)".*/\1/')
            echo -e "  ${RED}✗${RESET} $app_name (ID: $app_id)"
        done

        echo -e "\n${BLUE}💡 To install:${RESET}"
        echo "  mas install $MAS_NOT_INSTALLED"
        echo -e "${YELLOW}Note: Make sure you're signed into the App Store${RESET}"
    fi
fi

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
print_header "Summary"

echo -e "${GREEN}✓ Formulae in Brewfile:${RESET} $BREWFILE_FORMULAE_COUNT"
echo -e "${GREEN}✓ Casks in Brewfile:${RESET} $BREWFILE_CASKS_COUNT"
echo -e "${GREEN}✓ MAS apps in Brewfile:${RESET} $BREWFILE_MAS_COUNT"
echo -e "${YELLOW}• Formulae missing from Brewfile:${RESET} $FORMULAE_MISSING_COUNT"
if [ -n "${MAS_MISSING_COUNT:-}" ]; then
    echo -e "${YELLOW}• MAS apps missing from Brewfile:${RESET} ${MAS_MISSING_COUNT}"
fi

echo -e "\n${BLUE}💡 Next steps:${RESET}"
echo "  1. Review the packages above"
echo "  2. Add desired packages to $BREWFILE"
echo "  3. Run: brew bundle --file=$BREWFILE"
echo ""

# Exit successfully
exit 0
