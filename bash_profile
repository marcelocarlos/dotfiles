# Created by Marcelo C. Carlos
# Modified setup from https://github.com/mathiasbynens/dotfiles

for file in ~/.{bash_prompt,exports,aliases,functions}; do
	[ -r "$file" ] && source "$file"
done
unset file

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

if [ "$(uname)" == "Darwin" ]; then
	# Enabling bash-completion (you need to install it first - use brew for that!)
	if [ -f `brew --prefix`/etc/bash_completion ]; then
	. `brew --prefix`/etc/bash_completion
	fi
fi

