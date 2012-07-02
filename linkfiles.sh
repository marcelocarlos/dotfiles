#!/bin/bash

source functions

function linkIt() {
	echo -ne "Linking dotfiles ... " 
	for dotfile in $(/bin/ls -1); do
		FOLDER=$(realpath $dotfile)
		ln -s "$FOLDER/$dotfile" "$HOME/.$dotfile"
	done
	echo "[OK]"

	echo -ne "Linking templates ... " 
	ln -s $PWD"/templates" $HOME"/Documents/Templates" 
	echo "[OK]"
}

read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	linkIt
else
	return 100
fi
unset linkIt
source ~/.bash_profile
