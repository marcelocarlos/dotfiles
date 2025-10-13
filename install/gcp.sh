#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# GCP SDK specific installations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

source utils.sh

# ------------------------------------------------------------------------------
# GCloud CLI
# ------------------------------------------------------------------------------
print_h1 "gcloud components"

if command_exists gcloud; then
    print_info "Installing gcloud components..."
    gcloud components install gke-gcloud-auth-plugin --quiet

    print_info "Configuring GKE clusters..."
    bash install/gke.sh
else
    print_error "gcloud not found. Skipping component installation."
fi
