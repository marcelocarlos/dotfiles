#!/bin/bash

source functions

function copyIt() {
	echo -ne "Linking dotfiles ... "
	for dotfile in $(/bin/ls -1 | grep -v .sh | grep -v .md); do
		FOLDER=$(realpath $dotfile)
		cp -f "$FOLDER/$dotfile" "$HOME/.$dotfile"
	done
	echo "[OK]"
}

read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	copyIt
fi
unset copyIt

# apply the changes
source ~/.bash_profile
