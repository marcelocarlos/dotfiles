# shellcheck shell=bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# Environment variables and PATH configuration

# ------------------------------------------------------------------------------
# Editor and Pager
# ------------------------------------------------------------------------------
export EDITOR="vim"
export MANPAGER="less -X"
export LESS_TERMCAP_md="$GREEN"

# ------------------------------------------------------------------------------
# History
# ------------------------------------------------------------------------------
export HISTSIZE=100000
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL=ignoredups
export HISTTIMEFORMAT="%d-%h-%y %T | "

# ------------------------------------------------------------------------------
# Homebrew
# ------------------------------------------------------------------------------
export HOMEBREW_NO_GITHUB_API=1

# ------------------------------------------------------------------------------
# PATH Configuration
# ------------------------------------------------------------------------------
# Homebrew
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"

# User binaries
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# Go
export GOPATH="${GOPATH:-$HOME/go}"
export GOBIN="${GOBIN:-$GOPATH/bin}"
[ -d "$GOBIN" ] && export PATH="$GOBIN:$PATH"

# Man pages
export MANPATH="$(brew --prefix)/opt/coreutils/libexec/gnuman:$MANPATH"

# ------------------------------------------------------------------------------
# Tool Configuration
# ------------------------------------------------------------------------------
# Kubernetes
export KUBECTL_EXTERNAL_DIFF="colordiff -N -u"
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# GPG
export GPG_TTY=$(tty)
