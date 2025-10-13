#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# Custom bash prompt with git, cloud, and kubernetes context

# ------------------------------------------------------------------------------
# Color definitions
# ------------------------------------------------------------------------------
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
TURQUOISE="\[\033[00;36m\]"
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

tput sgr0

export BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE BOLD TURQUOISE RESET

# ------------------------------------------------------------------------------
# Terminal compatibility
# ------------------------------------------------------------------------------
if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
    export TERM=gnome-256color
elif infocmp xterm-256color >/dev/null 2>&1; then
    export TERM=xterm-256color
fi

# ------------------------------------------------------------------------------
# Git status parsing (optimized with porcelain format)
# ------------------------------------------------------------------------------
function parse_git_info {
    # Use porcelain format for faster parsing
    local git_status=$(git status --porcelain --branch 2>/dev/null)

    if [ -n "$git_status" ]; then
        local branch=""
        local remote=""
        local state=""

        # Parse first line for branch info
        # Format: ## branch...origin/branch [ahead 1, behind 2]
        local branch_line=$(echo "$git_status" | head -n1)

        if [[ $branch_line =~ ^\#\#\ HEAD\ \(no\ branch\) ]]; then
            branch="NO BRANCH"
        elif [[ $branch_line =~ ^\#\#\ ([^.\ ]+) ]]; then
            branch="${BASH_REMATCH[1]}"
        fi

        # Check for ahead/behind
        if [[ $branch_line =~ \[ahead\ ([0-9]+)\] ]]; then
            remote=" ▲(${BASH_REMATCH[1]})"
        elif [[ $branch_line =~ \[behind\ ([0-9]+)\] ]]; then
            remote=" ▼(${BASH_REMATCH[1]})"
        elif [[ $branch_line =~ \[ahead\ ([0-9]+),\ behind\ ([0-9]+)\] ]]; then
            remote=" (${BASH_REMATCH[1]})ⵖ(${BASH_REMATCH[2]})"
        fi

        # Check for changes (any lines beyond first = changes)
        if [ "$(echo "$git_status" | wc -l)" -gt 1 ]; then
            state=" *"
        fi

        # Color based on branch name
        # shellcheck disable=SC1087
        if [ "$branch" == "master" ] || [ "$branch" == "main" ]; then
            echo -ne "$RED[git: ${branch}${remote}${state}]$RESET "
        else
            echo -ne "$GREEN[git: ${branch}${remote}${state}]$RESET "
        fi
    fi
    return
}

# ------------------------------------------------------------------------------
# User display (red for root, turquoise for regular user)
# ------------------------------------------------------------------------------
function parse_user {
    if [ "$(id -u)" == "0" ]; then
        echo "\[${BOLD}${RED}\]\u\[$RESET\]"
    else
        echo "\[${BOLD}${TURQUOISE}\]\u\[$RESET\]"
    fi
}

# ------------------------------------------------------------------------------
# Kubernetes context (cached for performance)
# ------------------------------------------------------------------------------
__k8s_context=""
__k8s_context_check=0

function k8s_context {
    # Cache context info, refresh every 5 prompts
    if [ "$__k8s_context_check" -eq 0 ] && command -v kubectl &> /dev/null; then
        local stage=$(kubectl config current-context 2>/dev/null)
        local ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
        [ -z "$ns" ] && ns="default"

        if [ -n "$stage" ]; then
            if [ "$stage" == "production" ]; then
                __k8s_context="${BOLD}${RED}[k8s: $stage/$ns]${RESET} "
            else
                __k8s_context="${GREEN}[k8s: $stage/$ns]${RESET} "
            fi
        else
            __k8s_context=""
        fi
        __k8s_context_check=5
    fi

    [ "$__k8s_context_check" -gt 0 ] && ((__k8s_context_check--))
    [ -n "$__k8s_context" ] && echo -ne "$__k8s_context"
}

# ------------------------------------------------------------------------------
# GCloud config (if gcloud available)
# ------------------------------------------------------------------------------
function gcloud_config {
    if command -v gcloud &> /dev/null && [ -f ~/.config/gcloud/active_config ]; then
        local stage=$(cat ~/.config/gcloud/active_config 2>/dev/null)
        if [ -n "$stage" ]; then
            if [ "$stage" == "production" ]; then
                echo -ne "${BOLD}${RED}[gcp: $stage]${RESET} "
            else
                echo -ne "${GREEN}[gcp: $stage]${RESET} "
            fi
        fi
    fi
}

# ------------------------------------------------------------------------------
# Terraform workspace (cached for performance)
# ------------------------------------------------------------------------------
__tf_workspace=""
__tf_workspace_dir=""

function terraform_workspace {
    # Only check if in a terraform directory
    if [ -d .terraform ]; then
        # Cache workspace, only re-read if directory changed
        if [ "$PWD" != "$__tf_workspace_dir" ]; then
            __tf_workspace=$(terraform workspace show 2>/dev/null)
            __tf_workspace_dir="$PWD"
        fi

        # Only show non-default workspaces
        if [ -n "$__tf_workspace" ] && [ "$__tf_workspace" != "default" ]; then
            if [ "$__tf_workspace" == "production" ]; then
                echo -ne "${BOLD}${RED}[tf: $__tf_workspace]${RESET} "
            else
                echo -ne "${GREEN}[tf: $__tf_workspace]${RESET} "
            fi
        fi
    else
        # Clear cache when leaving terraform directory
        __tf_workspace=""
        __tf_workspace_dir=""
    fi
}

# ------------------------------------------------------------------------------
# Assemble PS1
# ------------------------------------------------------------------------------
function get_ps1 {
    local exit_status="$?"
    local exit_display

    # Color exit status
    if [ "${exit_status}" -eq 0 ]; then
        exit_display="${GREEN}${exit_status}${RESET}"
    else
        exit_display="${RED}${exit_status}${RESET}"
    fi

    # Gather context info from functions
    local user_info=$(parse_user)
    local git_info=$(parse_git_info)
    local gcp_info=$(gcloud_config)
    local k8s_info=$(k8s_context)
    local tf_info=$(terraform_workspace)

    # Build prompt
    PS1="\[$BOLD\]\[$GREEN\]\w\[$BLACK\] - ${user_info} - \D{%T} - ${exit_display}] ${git_info}${gcp_info}${k8s_info}${tf_info}\[$BOLD\]\[$BLACK\]\n\$ \[$RESET\]"
}

PROMPT_COMMAND=get_ps1
