# Created by Marcelo C. Carlos
# Modified setup from https://github.com/mathiasbynens/dotfiles

for file in $(ls ~/.dotfile_src_*); do
    [ -r "$file" ] && source "$file"
done
unset file

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Make multi-line commandsline in history
shopt -q -s cmdhist

# Make sure display get updated when terminal window get resized
shopt -q -s checkwinsize

if [ "$(uname)" == "Darwin" ]; then
    # Enabling bash-completion (you need to install it first - use brew for that!)
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
        . $(brew --prefix)/etc/bash_completion
    fi
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# show the number of failed login attempts
if [ -f "/var/log/auth.log" ] ; then
    echo -e "Failed login attempts: $(grep 'Failed password' /var/log/auth.log* | wc -l)"
fi

# initialize rbenv 
eval "$(rbenv init -)"

# initialize gpg daemon
eval $(gpg-agent --daemon)

# awscli completion
complete -C aws_completer aws

function cd {
    builtin cd "$@"
    if [ -d ".git" ]; then
        grep "git secrets --pre_commit_hook" .git/hooks/pre-commit -q 2> /dev/null
        if [ ! $? -eq 0 ]; then
            git secrets --install
        fi
    fi
}
