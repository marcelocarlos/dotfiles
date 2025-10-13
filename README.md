# Marcelo's dotfiles

Production-ready, modular dotfiles for macOS that enable: **fresh macOS installation → run setup → complete development environment**.

Inspired by [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles). Feel free to explore, learn, copy, and suggest improvements!

## Features

- **Modular architecture** - Enable only what you need via toggles
- **Language environments** - Python, Node.js, Go with modern tooling
- **Development tools** - direnv, GPG/YubiKey, Powerline fonts
- **macOS automation** - System preferences setup and backup/restore
- **Idempotent scripts** - Safe to run multiple times
- **Local overrides** - Machine-specific configs not tracked in git

## Quick Start

```bash
# 1. Install Xcode Command Line Tools (if needed)
xcode-select --install

# 2. Clone the repository
git clone https://github.com/marcelocarlosbr/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 3. Review Brewfile (optional - customize packages)
# See: Brewfile

# 4. Run setup
./setup.sh

# 5. Enable features (edit .dotfiles.conf and rerun setup.sh)
# Uncomment lines for Python, Node, Go, GPG, fonts, etc.
./setup.sh
```

On first run, `setup.sh` creates `.dotfiles.conf` from the example template. Edit it to enable optional features (languages, tools, macOS settings), then run `./setup.sh` again.

## Structure

```text
dotfiles/
├── setup.sh                 # Main orchestrator
├── .dotfiles.conf.example   # Configuration template
├── Brewfile                 # Homebrew packages (link below)
├── install/                 # Modular install scripts
│   ├── bash.sh              # Bash shell setup
│   ├── git.sh               # Git configuration
│   ├── homebrew.sh          # Homebrew + Brewfile
│   ├── ...                  # Many more ...
├── shell/                   # Shell configuration
│   ├── bash_profile        # Main entry point, loads modules
│   ├── exports.sh          # Environment variables, PATH
│   ├── aliases.sh          # Command aliases
│   ├── functions.sh        # Useful shell functions
│   ├── prompt.sh           # Bash prompt (git, k8s, gcp, terraform)
│   └── completions.sh      # Auto-completions
├── config/                  # Application configs
│   ├── git/                # gitconfig, gitignore
│   ├── vim/                # vimrc
│   └── misc/               # inputrc, wgetrc
└── scripts/                 # Utility scripts
    ├── macos-settings-backup.sh
    ├── macos-settings-restore.sh
    ├── brewfile-sync.sh
    └── setup-git-hooks.sh
```

## Configuration

### Enabling Features

Edit `.dotfiles.conf` (created on first run) and uncomment lines to enable features such as GPG, GCP, etc.

See [.dotfiles.conf.example](.dotfiles.conf.example) for full configuration options.

### Local Customizations

Create these files for machine-specific settings (not tracked in git):

```bash
# ~/.bashrc.local - Shell customizations
export PATH="$HOME/work/bin:$PATH"
alias work='cd ~/work/projects'

# ~/.gitconfig.local - Git customizations
[user]
    email = work@example.com

# .envrc - Directory-specific environment (with direnv)
export AWS_PROFILE=myprofile
export NODE_ENV=development
```

## What Gets Installed

### Core Tools (Always Installed)

- **Homebrew** - Package manager for macOS
- **Bash** - Latest bash shell
- **Git** - Version control with custom configuration

### Language Environments (Optional)

- **Python** - Modern tooling: [uv](https://github.com/astral-sh/uv) (fast pip), [pipx](https://github.com/pypa/pipx) (isolated tools), [ruff](https://github.com/astral-sh/ruff) (linter), [bandit](https://github.com/PyCQA/bandit) (security)
- **Node.js** - npm + yarn (via [corepack](https://nodejs.org/api/corepack.html))
- **Go** - [gopls](https://pkg.go.dev/golang.org/x/tools/gopls) (LSP) + [golangci-lint](https://golangci-lint.run/) (meta-linter)

### Development Tools (Optional)

- **[direnv](https://direnv.net/)** - Per-directory environment variables (auto-loads/unloads on cd)
- **GPG** - Commit signing with YubiKey support
- **Powerline Fonts** - For enhanced terminal display
- **macOS Settings** - Automated system preferences (Dock, Finder, keyboard, trackpad)

### Additional Packages

See [Brewfile](./Brewfile) for browsers, productivity apps, cloud tools (AWS, GCP, k8s), DevOps tools (Docker, Terraform), and utilities.

## Customization Guide

### Adding Custom Scripts

Place custom install scripts in `install/` and call them from `setup.sh`:

```bash
if [[ "${MY_FEATURE:-}" == "true" ]]; then
    bash install/my-feature.sh
fi
```

### Machine-Specific Settings

Settings not tracked in git:

- **`~/.gitconfig.local`** - Created automatically by `git.sh` (prompts for email and GPG key)
- **`~/.bashrc.local`** - Optional shell customizations (create manually if needed)
- **`.envrc`** - Per-project environment with direnv (create in project directories)

### macOS Settings Backup/Restore

```bash
# Backup current macOS settings
bash scripts/macos-settings-backup.sh

# Restore from backup
bash scripts/macos-settings-restore.sh ~/.dotfiles/backups/macos-settings-YYYYMMDD.json
```

### Brewfile Sync

Compare installed packages with Brewfile to keep them in sync:

```bash
# Check what's installed vs what's in Brewfile
bash scripts/brewfile-sync.sh
```

This shows:

- Packages installed but not in Brewfile (with copy-paste commands to add them)
- Packages in Brewfile but not installed
- Apps in /Applications not managed by Homebrew

### Git Hooks (Secret Scanning)

Prevent committing secrets to your repository:

```bash
# Setup git-secrets pre-commit hooks
bash scripts/setup-git-hooks.sh
```

This configures:

- Pre-commit hook to scan files before committing
- AWS secret patterns (access keys, tokens)
- Custom patterns (passwords, API keys, private keys)
- Scans existing repository and git history

Once installed, commits with secrets will be automatically blocked.

## Usage Tips

### Updating Dotfiles

```bash
cd ~/dotfiles
git pull
./setup.sh  # Re-run to apply updates
```

### Using direnv

Create `.envrc` in any project directory:

```bash
cd ~/myproject
echo 'export DATABASE_URL=postgresql://localhost/mydb' > .envrc
direnv allow  # Grant permission (one-time)
# Environment auto-loads when entering directory
```

## Contributing

Suggestions and improvements welcome! Open an issue or submit a pull request.

## License

MIT License - Feel free to use and modify.

## Credits

- Inspired by [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
- Created by [Marcelo Carlos](https://marcelocarlos.com)
