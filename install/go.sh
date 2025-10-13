#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlos/dotfiles
#
# Setup Go development environment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

# ------------------------------------------------------------------------------
# Go Development Setup
# ------------------------------------------------------------------------------
print_h1 "Setting up Go Development Environment"

# ------------------------------------------------------------------------------
# Validate Go Installation
# ------------------------------------------------------------------------------
print_h2 "Validating Go installation"

if ! command_exists go; then
    print_error "Error: Go is not installed"
    print_yellow "Install Go via Homebrew: brew install go"
    exit 1
fi

GO_VERSION=$(go version)
print_green "Go installed: $GO_VERSION"

# Verify go fmt works (built-in formatter)
if go help fmt &>/dev/null; then
    print_green "go fmt available (built-in formatter)"
else
    print_yellow "Warning: go fmt not working correctly"
fi

# ------------------------------------------------------------------------------
# Configure Go Environment
# ------------------------------------------------------------------------------
print_h2 "Configuring Go environment"

# Get current GOPATH and GOBIN
GOPATH=$(go env GOPATH)
GOBIN=$(go env GOBIN)

print_green "GOPATH: $GOPATH"

if [ -z "$GOBIN" ]; then
    GOBIN="$GOPATH/bin"
    print_yellow "GOBIN not set, using default: $GOBIN"
else
    print_green "GOBIN: $GOBIN"
fi

# Ensure GOBIN directory exists
if [ ! -d "$GOBIN" ]; then
    mkdir -p "$GOBIN"
    print_green "Created $GOBIN"
else
    print_green "GOBIN directory exists"
fi

# Check if GOBIN is in PATH
if [[ ":$PATH:" != *":$GOBIN:"* ]]; then
    print_yellow "Warning: $GOBIN is not in PATH"
    print_yellow "Add to your shell config: export PATH=\"\$GOPATH/bin:\$PATH\""
else
    print_green "GOBIN is in PATH"
fi

# ------------------------------------------------------------------------------
# Install Go Development Tools
# ------------------------------------------------------------------------------
print_h2 "Installing Go development tools"

echo ""
print_yellow "Installing gopls (Go language server)..."
if go install golang.org/x/tools/gopls@latest; then
    print_success "gopls installed"
else
    print_red "✗ gopls installation failed"
fi

echo ""
print_yellow "Installing golangci-lint (meta-linter with 50+ linters including staticcheck)..."
if go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest; then
    print_success "golangci-lint installed"
else
    print_red "✗ golangci-lint installation failed"
fi

# ------------------------------------------------------------------------------
# Verify Installed Tools
# ------------------------------------------------------------------------------
print_h2 "Verifying installed tools"

echo ""
TOOLS=("gopls" "golangci-lint")

for tool in "${TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null; then
        VERSION=$("$tool" version 2>&1 | head -1 || echo "version unknown")
        print_success "$tool: $VERSION"
    else
        print_yellow "✗ $tool: not found in PATH"
    fi
done

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
echo ""
print_h1 "Go Development Environment Ready!"
echo ""
print_green "Installed tools:"
echo "  • go         - Go compiler and toolchain ($GO_VERSION)"
echo "  • go fmt     - Code formatter (built-in)"
echo "  • gopls      - Language server for IDE/editor support"
echo "  • golangci-lint - Meta-linter with 50+ linters (includes staticcheck)"
echo ""
print_yellow "Quick start:"
echo "  go mod init <module>        # Initialize a new Go module"
echo "  go build                    # Build your application"
echo "  go test ./...               # Run tests"
echo "  go fmt ./...                # Format code"
echo "  golangci-lint run           # Run all linters (includes staticcheck)"
echo ""
print_success "Done"
