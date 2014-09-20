# Marcelo's dotfiles

## Installation

### Using Git (Recommended)

Clone the repository wherever you want and the linkfile.sh script will do the rest.

```bash
git clone --recursive https://github.com/marcelocarlosbr/dotfiles.git
cd dotfiles
./install.sh -lf # remove '-ĺ' if you want to copy instead of symlink; remove '-f' to be prompted before every delete/overwrite action.
```

### Without Git

To install these dotfiles without Git (note that this method will not download the plugins for vim automatically):

```bash
wget https://github.com/marcelocarlosbr/dotfiles/archive/master.zip
unzip master
cd dotfiles-master
./install.sh -f # remove '-f' to be prompted before every delete/overwrite action.
```

After that you can remove the dotfiles-master folder, since in this installation type the files are copied rather than linked
