#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# GKE cluster configuration script

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

source utils.sh

# ------------------------------------------------------------------------------
# GKE Cluster Configuration
# ------------------------------------------------------------------------------
print_h1 "Configuring GKE clusters"

CONFIG_FILE="../config/gcp/gke_clusters.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
    print_yellow "No gke_clusters.yaml found. Skipping GKE cluster configuration."
    print_yellow "Copy gke_clusters.yaml.example to gke_clusters.yaml and customize it."
    exit 0
fi

if ! command_exists yq; then
    print_error "yq is not installed. Please install it to continue."
    exit 1
fi

if ! command_exists gcloud; then
    print_error "gcloud is not installed. Please install it to continue."
    exit 1
fi

if ! command_exists kubectl; then
    print_error "kubectl is not installed. Please install it to continue."
    exit 1
fi

if ! command_exists jq; then
    print_error "jq is not installed. Please install it to continue."
    exit 1
fi

# Convert YAML to JSON and loop through clusters
for cluster in $(yq -o=json '.' "$CONFIG_FILE" | jq -r '.clusters[] | @base64'); do
    _jq() {
     echo ${cluster} | base64 --decode | jq -r ${1}
    }

    name=$(_jq '.name')
    project=$(_jq '.project')
    region=$(_jq '.region')
    zone=$(_jq '.zone')
    alias=$(_jq '.alias')

    print_info "Fetching credentials for cluster: $name"

    cmd="gcloud container clusters get-credentials $name --project $project"
    if [ "$region" != "null" ]; then
        cmd="$cmd --region $region"
    elif [ "$zone" != "null" ]; then
        cmd="$cmd --zone $zone"
    else
        print_error "Cluster $name has no region or zone defined. Skipping."
        continue
    fi

    if ! $cmd; then
        print_error "Failed to get credentials for cluster: $name"
        continue
    fi

    # Get the current context name
    context_name=$(kubectl config current-context)

    print_info "Renaming context from '$context_name' to '$alias'"
    if ! kubectl config rename-context "$context_name" "$alias"; then
        print_error "Failed to rename context for cluster: $name"
    fi
done

print_green "GKE cluster configuration complete."
