#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# Setup Python development environment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

# ------------------------------------------------------------------------------
# Python Development Setup
# ------------------------------------------------------------------------------
print_h1 "Setting up Python Development Environment"

# ------------------------------------------------------------------------------
# Validate Python Installation
# ------------------------------------------------------------------------------
print_h2 "Validating Python installation"

if ! command_exists python3; then
    print_error "Error: Python 3 is not installed"
    print_yellow "Install Python via Homebrew: brew install python"
    exit 1
fi

PYTHON_VERSION=$(python3 --version)
print_green "Python installed: $PYTHON_VERSION"

# ------------------------------------------------------------------------------
# Validate Python Development Tools
# ------------------------------------------------------------------------------
print_h2 "Validating Python development tools"

TOOLS=("uv" "pipx" "ruff" "bandit")
MISSING_TOOLS=()

for tool in "${TOOLS[@]}"; do
    if command_exists "$tool"; then
        VERSION=$("$tool" --version 2>&1 | head -1)
        print_success "$tool: $VERSION"
    else
        print_yellow "✗ $tool: not installed"
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo ""
    print_yellow "Missing tools: ${MISSING_TOOLS[*]}"
    print_yellow "Install via Homebrew: brew install ${MISSING_TOOLS[*]}"
    echo ""
fi

# ------------------------------------------------------------------------------
# Configure pipx
# ------------------------------------------------------------------------------
if command_exists pipx; then
    print_h2 "Configuring pipx"

    # Ensure pipx path
    PIPX_BIN_DIR="$HOME/.local/bin"

    if [ ! -d "$PIPX_BIN_DIR" ]; then
        mkdir -p "$PIPX_BIN_DIR"
        print_green "Created $PIPX_BIN_DIR"
    fi

    # Check if path is in PATH
    if [[ ":$PATH:" != *":$PIPX_BIN_DIR:"* ]]; then
        print_yellow "Note: $PIPX_BIN_DIR is not in PATH"
        print_yellow "Add to your shell config or run: export PATH=\"\$HOME/.local/bin:\$PATH\""
    else
        print_green "pipx bin directory is in PATH"
    fi

    # Ensure pipx paths are configured
    pipx ensurepath --force > /dev/null 2>&1 || true
    print_green "pipx configured"
fi

# ------------------------------------------------------------------------------
# Configure uv
# ------------------------------------------------------------------------------
if command_exists uv; then
    print_h2 "Configuring uv"

    # uv is ready to use out of the box
    print_green "uv is ready to use as a fast pip replacement"
    echo ""
    print_yellow "Usage examples:"
    echo "  uv pip install <package>  # Fast package installation"
    echo "  uv pip list               # List installed packages"
    echo "  uv venv                   # Create virtual environment"
fi

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
echo ""
print_h1 "Python Development Environment Ready!"
echo ""
print_green "Installed tools:"
echo "  • python3   - Python interpreter"
echo "  • uv        - Fast package installer (use instead of pip)"
echo "  • pipx      - Install CLI tools in isolation"
echo "  • ruff      - Fast linter/formatter"
echo "  • bandit    - Security linter"
echo ""
print_yellow "Quick start:"
echo "  uv pip install <package>      # Install packages with uv"
echo "  pipx install <tool>           # Install CLI tools (e.g., black, pytest)"
echo "  ruff check .                  # Lint your Python code"
echo "  bandit -r .                   # Security scan your code"
echo ""
print_success "Done"
