#!/bin/bash

source functions

function copyIt() {
	echo -ne "Copying dotfiles ... "
	for dotfile in $(/bin/ls -1 | grep -v files.sh | grep -v README.md); do
		FOLDER=$(realpath $dotfile)
		if [ -e "$HOME/.$dotfile" ]; then
			rm "$HOME/.$dotfile"
		fi
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
