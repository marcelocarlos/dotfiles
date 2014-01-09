#!/bin/bash

source functions

function linkIt() {
	echo -ne "Linking dotfiles ... "
	for dotfile in $(/bin/ls -1B -I *.sh -I *.md); do
		FOLDER=$(realpath $dotfile)
		ln -s "$FOLDER/$dotfile" "$HOME/.$dotfile"
	done
	echo "[OK]"
}

read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	linkIt
fi
unset linkIt

# apply the changes
source ~/.bash_profile
