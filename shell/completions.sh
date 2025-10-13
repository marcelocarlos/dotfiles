# shellcheck shell=bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# Shell completions for various tools

# ------------------------------------------------------------------------------
# Bash completion
# ------------------------------------------------------------------------------
if [ "$(uname)" == "Darwin" ]; then
    if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
        . "$(brew --prefix)/etc/bash_completion"
    fi
fi

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# ------------------------------------------------------------------------------
# AWS CLI
# ------------------------------------------------------------------------------
if command -v aws_completer &> /dev/null; then
    complete -C aws_completer aws
fi

# ------------------------------------------------------------------------------
# Kubectl
# ------------------------------------------------------------------------------
if command -v kubectl &> /dev/null; then
    source <(kubectl completion bash)
    # Enable completion for alias
    complete -F __start_kubectl k
fi

# ------------------------------------------------------------------------------
# GCloud
# ------------------------------------------------------------------------------
if [[ "$ENABLE_GCP" == "true" ]] && [ -f "$(brew --prefix)/Caskroom/gcloud-cli/latest/google-cloud-sdk/completion.bash.inc" ]; then
    source "$(brew --prefix)/Caskroom/gcloud-cli/latest/google-cloud-sdk/completion.bash.inc"
fi

# ------------------------------------------------------------------------------
# Vault
# ------------------------------------------------------------------------------
if command -v vault &> /dev/null; then
    complete -C "$(which vault)" vault
fi

# ------------------------------------------------------------------------------
# Terraform
# ------------------------------------------------------------------------------
if command -v terraform &> /dev/null; then
    complete -C "$(which terraform)" tf
    complete -C "$(which terraform)" terraform
fi

# ------------------------------------------------------------------------------
# Docker
# ------------------------------------------------------------------------------
if command -v docker &> /dev/null; then
    source <(docker completion bash)
fi

# ------------------------------------------------------------------------------
# GitHub CLI
# ------------------------------------------------------------------------------
if command -v gh &> /dev/null; then
    eval "$(gh completion -s bash)"
fi

# ------------------------------------------------------------------------------
# Kind
# ------------------------------------------------------------------------------
if command -v kind &> /dev/null; then
    source <(kind completion bash)
fi

# ------------------------------------------------------------------------------
# Kustomize
# ------------------------------------------------------------------------------
if command -v kustomize &> /dev/null; then
    source <(kustomize completion bash)
fi

# ------------------------------------------------------------------------------
# Helm
# ------------------------------------------------------------------------------
if command -v helm &> /dev/null; then
    source <(helm completion bash)
fi
