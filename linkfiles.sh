#!/bin/bash
# copyfile.sh
# Copyright 2012 - Marcelo Carlos (contact@marcelocarlos.com)
# Distributed under the terms of the GNU General Public License, v2 or later

source functions

# GLOBAL VARIABLES
APP_NAME=$(basename $0)
APP_PATH=$(dirname "$0")

FORCE_W=0

function usage() {
    cat << EOF
Usage: $APP_NAME [options]

Options:
    -f          overwrite files without asking for confirmation
    -h          show this menu

EOF
}

# a colon means that a parameter is expected after the option selected
while getopts "hf" OPTION
do
    case $OPTION in
        f)
            FORCE_W=1
            ;;
        ?)
            usage
            exit
            ;;
    esac
done

function linkIt() {
    echo -ne "Linking dotfiles ... "
    for dotfile in $(/bin/ls -1 | grep -Fv .sh | grep -Fv .md); do
        FOLDER=$(realpath $dotfile)
        if [ -e "$HOME/.$dotfile" ] || [ -L "$HOME/.$dotfile" ]; then
            rm -f "$HOME/.$dotfile"
        fi
        if [ -d $dotfile ]; then
            ln -s "$FOLDER" "$HOME/.$dotfile"
        else
            ln -s "$FOLDER/$dotfile" "$HOME/.$dotfile"
        fi
    done
    echo "[OK]"
}

if [ $FORCE_W == 0 ]; then
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        linkIt
    fi
else
    linkIt
fi

unset linkIt

# apply the changes
source ~/.bash_profile
