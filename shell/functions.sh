# shellcheck shell=bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
#
# Shell functions

# ------------------------------------------------------------------------------
# Directory Management
# ------------------------------------------------------------------------------
# Create a new directory and enter it
function md() {
    mkdir -p "$@" && cd "$@" || return
}

# Get real path of a file or directory
function realpath() {
    local FOLDER="$1"
    if [ -f "$1" ]; then
        FOLDER=$(dirname "$1")
    fi
    cd "$FOLDER" || return
    echo "$PWD"
    cd - >> /dev/null || return
    return 0
}
export -f realpath

# ------------------------------------------------------------------------------
# Java Version Switching
# ------------------------------------------------------------------------------
# Quick switch JDK versions
# Usage: jdk 15
function jdk() {
    version=$1
    export JAVA_HOME=$(/usr/libexec/java_home -v"$version");
    java -version
}

# ------------------------------------------------------------------------------
# Date/Time Utilities
# ------------------------------------------------------------------------------
# Convert timestamp to date
function timestamp2date() {
    echo "$(date -d @${1})"
}
