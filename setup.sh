#!/usr/bin/env bash
# Created by Marcelo Carlos (contact@marcelocarlos.com)
# Source: https://github.com/marcelocarlosbr/dotfiles
set -euo pipefail

SCRIPT_NAME=$(basename $0)
BASE_DIR=$(dirname "$0")
if [[ "$BASE_DIR" == "." ]] ; then
    BASE_DIR=$(pwd)
fi
CMD_FLAGS=''

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [options]

Options:
    -f          force, overwrite files without asking for confirmation
    -h          show this menu

EOF
}

# $1 line (partials allowed)
# $2 file
contains_line() {
  grep -q "$1" "$2"
}

print_h1() {
  echo "$(tput bold)# ------------------------------------------------------------------------------$(tput sgr0)"
  echo "$(tput bold)# $* $(tput sgr0)"
  echo "$(tput bold)# ------------------------------------------------------------------------------$(tput sgr0)"
}

print_h2() {
  echo "$(tput bold)## $* $(tput sgr0)"
}

print_green() {
  echo "$(tput setaf 2)$* $(tput sgr0)"
}

print_yellow() {
  echo "$(tput setaf 3)$* $(tput sgr0)"
}

function dotfiles_setup() {
    for dotfile in $(ls -1 ${BASE_DIR}/dot); do
      ln -s ${CMD_FLAGS} "${BASE_DIR}/dot/$dotfile" "$HOME/.$dotfile"
    done
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
while getopts "hfl" OPTION
do
    case $OPTION in
        f)
            CMD_FLAGS='-f'
            ;;
        h)
            usage
            exit 0
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done

# ------------------------------------------------------------------------------
# Installing pre-requisites
# ------------------------------------------------------------------------------
print_h1 "Installing pre-requisites"
# install homebrew if not installed yet
if ! brew --version > /dev/null 2>&1; then
  print_h2 "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
print_green "Done." && echo

# ------------------------------------------------------------------------------
# Installing Applications
# ------------------------------------------------------------------------------
print_h1 "Installing Applications"
# install applications
print_yellow "Open the App Store and login to it before continuing. Press <enter> to continue"
read
brew bundle
print_green "Done." && echo

# ------------------------------------------------------------------------------
# Dotfiles
# ------------------------------------------------------------------------------
print_h1 "Setting up Dotfiles"
# Setup dotfile
dotfiles_setup
print_green "Done." && echo

# ------------------------------------------------------------------------------
# Finishing setup
# ------------------------------------------------------------------------------
print_h1 "Finishing setup"
# Update default bash
if ! contains_line "/usr/local/bin/bash" "/etc/shells"; then
  echo "/usr/local/bin/bash" | sudo tee -a /etc/shells
  chsh -s /usr/local/bin/bash
fi

# post-setup - git
SETUP_GIT_CONFIG='n'
if [ -f "$HOME/.gitconfig.local" ]; then
  read -p  "It seeems $HOME/.gitconfig.local, do you want to re-create it? [Y/n] " ANSWER
  if [ "$ANSWER" != "n" ]; then
    SETUP_GIT_CONFIG='y'
  fi
else
  SETUP_GIT_CONFIG='y'
fi
if [ ${SETUP_GIT_CONFIG} == 'y' ]; then
  read -p "Git email address: " GIT_EMAIL
  echo -e "[user]\nemail = $GIT_EMAIL" > ~/.gitconfig.local
  read -p  "Setup GPG? [Y/n] " ANSWER
  if [ "$ANSWER" != "n" ]; then
    echo "Available GPG keys: "
    gpg --list-secret-keys --keyid-format LONG
    read -p "GPG signing key (value from 'sec', after '/'): " GPG_KEY
    echo "signingkey = $GPG_KEY" >> ~/.gitconfig.local
    echo -e "[commit]\ngpgsign = true" >> ~/.gitconfig.local
    echo -e "[gpg]\nprogram = gpg" >> ~/.gitconfig.local
  fi
fi

# remove quarantine from Quicklook plugins
# xattr -r ~/Library/QuickLook # To see the attributes
xattr -d -r com.apple.quarantine ~/Library/QuickLook
qlmanage -r

# remove quarantine from specific apps
# xattr -r /Applications/ # To see all
xattr -d -r com.apple.quarantine /Applications/BetterZip.app

# python setup
python3 -m pip install --upgrade setuptools
python3 -m pip install --upgrade pip
python3 -m pip install virtualenv
python3 -m pip install yq
# needed by vim plugin https://github.com/Shougo/deoplete.nvim
python3 -m pip install pynvim

# ruby setup
GLOBAL_RUBY_VERSION="2.7.2"
if [ "$(rbenv versions | grep -F ${GLOBAL_RUBY_VERSION} &> /dev/null)$?" -gt 0 ]; then
  rbenv install ${GLOBAL_RUBY_VERSION}
  rbenv global ${GLOBAL_RUBY_VERSION}
fi
eval "$(rbenv init -)"
# Check that bundler is installed
if [ "$(which bundle &> /dev/null)$?" -gt 0 ]; then
  gem install bundler
  rbenv rehash
fi
gem install rubocop

# docker completions
ln -sf /Applications/Docker.app/Contents/Resources/etc/docker.bash-completion /usr/local/etc/bash_completion.d/docker.bash-completion
ln -sf /Applications/Docker.app/Contents/Resources/etc/docker-machine.bash-completion /usr/local/etc/bash_completion.d/docker-machine.bash-completion
ln -sf /Applications/Docker.app/Contents/Resources/etc/docker-compose.bash-completion /usr/local/etc/bash_completion.d/docker-compose.bash-completion

# git-secrets
git secrets --register-aws --global

# pinentry
if ! contains_line "pinentry-program /usr/local/bin/pinentry-mac" "$HOME/.gnupg/gpg-agent.conf"; then
  echo "pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
fi

# fzf
$(brew --prefix)/opt/fzf/install

# iterm2
wget https://raw.githubusercontent.com/nathanbuchar/atom-one-dark-terminal/master/scheme/iterm/One%20Dark.itermcolors
open One\ Dark.itermcolors
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts
rm -f One\ Dark.itermcolors
echo
print_yellow "IMPORTANT: Open iterm2 preferences (General > Preferences) and ensure you set 'Load preferences from ...' to $BASE_DIR/iterm so iterm2 settings are loaded"
echo

# apply the changes to the current session
set +eu
source ~/.bash_profile
set -eu
print_green "Done."
echo

print_green "$(tput bold)All done! Enjoy!"