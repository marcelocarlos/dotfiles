#!/bin/bash
# copyfile.sh
# Copyright 2014 - Marcelo Carlos (contact@marcelocarlos.com)

# ------------------------------------------------------------------------------
# Settings
# ------------------------------------------------------------------------------
# GLOBAL VARIABLES
APP_NAME=$(basename $0)
APP_PATH=$(dirname "$0")
if [[ "$APP_PATH" == "." ]] ; then
    APP_PATH=$(pwd)
fi
FORCE_W=0
LINK_FILES=0
EXTRA_PARAM='-i' # prompt at every removal / before overwrite

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

function usage() {
    cat << EOF
Usage: $APP_NAME [options]

Options:
    -f          force, overwrite files without asking for confirmation
    -l          link files instead of copying
    -h          show this menu

EOF
}

function install_it() {
    echo "Installing ... "
    for dotfile in $(/bin/ls -1 ${APP_PATH} | grep -Fv .sh | grep -Fv .md); do
        if [ -e "$HOME/.$dotfile" ] || [ -L "$HOME/.$dotfile" ]; then
            rm -r ${EXTRA_PARAM} "$HOME/.$dotfile"
        fi
        if [ $LINK_FILES == 0 ]; then
            cp -r ${EXTRA_PARAM} "${APP_PATH}/$dotfile" "$HOME/.$dotfile"
        else
            ln -s ${EXTRA_PARAM} "${APP_PATH}/$dotfile" "$HOME/.$dotfile"
        fi
    done
    echo "Done."
    echo ""
}

# ------------------------------------------------------------------------------
# Main part of the script
# ------------------------------------------------------------------------------
while getopts "hfl" OPTION
do
    case $OPTION in
        f)
            FORCE_W=1
            EXTRA_PARAM='-f'
            ;;
        l)
            LINK_FILES=1
            ;;
        h)
            usage
            exit 0
            ;;
        ?)
            usage
            exit 128
            ;;
    esac
done

install_it

unset install_it

# apply the changes
source ~/.bash_profile

exit 0
