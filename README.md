# Marcelo's dotfiles

This repository serves me as a way to help me setup and maintain my Mac and share settings and ideas that might be useful. Inspired by [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles). Feel free to explore, learn, copy and suggest improvements. Enjoy!

## Installation

I strongly recommend you to have a look at the files in this repo before starting. The minimum I suggest to to check the [Brewfile](./Brewfile) to ensure the applications in there suit your needs. Once you are happy with it, run:

```shell
# if you don't want to clone the repo, you can download the files using:
# curl -LO https://github.com/marcelocarlosbr/dotfiles/archive/master.zip && unzip master
git clone https://github.com/marcelocarlosbr/dotfiles.git
cd dotfiles # 'cd dotfiles-master' if you downloaded the zip file instead of cloning the repo
./setup.sh
```

The setup command will install the applications defined in the [`Brewfile`](./Brewfile) and setup a series of dotfiles to fine tune items such as environment variables, aliases, completions, vim, and others. You can easily add custom dotfiles and have them sourced automatically by adding them to your `$HOME` directory using the prefix `.dot_` (e.g. `~/.dot_my_custom_file`).
