# Marcelo's dotfiles

## Installation

### Using Git (Recommended)

Clone the repository wherever you want and the linkfile.sh script will do the rest.

```bash
git clone https://github.com/marcelocarlosbr/dotfiles.git
cd dotfiles
git submodule update --init
./linkfiles.sh
```

### Without Git

To install these dotfiles without Git (note that this method will not download the plugins for vim automatically):

```bash
wget https://github.com/marcelocarlosbr/dotfiles/archive/master.zip
unzip master
cd dotfiles-master
./copyfiles.sh
```

After that you can remove the dotfiles-master folder, since in this installation type the files are copied rather than linked
