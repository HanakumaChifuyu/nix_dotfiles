# Installation Scripts Documentation

This directory includes automated installation and uninstallation scripts for easy setup and cleanup.

## Quick Start

### Installation

```bash
# Download and install
git clone <repo-url> /tmp/nvim-config
cd /tmp/nvim-config
./install.sh
```

### Uninstallation

```bash
cd ~/.config/nvim
./uninstall.sh
```

## install.sh

### Overview

Automated installation script that handles:
- System requirements checking
- Dependency installation
- Configuration backup
- Plugin installation
- Optional Nerd Font installation

### Usage

```bash
./install.sh [OPTIONS]
```

### Options

| Option | Description |
|--------|-------------|
| (none) | Interactive installation with prompts |
| `--auto` | Automatic mode, skip all confirmations |
| `--skip-backup` | Don't backup existing configuration |
| `--help` | Display help message |

### Examples

**Interactive Installation (Recommended)**
```bash
./install.sh
```
The script will ask for confirmation at each step.

**Fully Automatic Installation**
```bash
./install.sh --auto
```
Automatically install everything without prompts. Useful for scripts or CI/CD.

**Install Without Backup**
```bash
./install.sh --skip-backup
```
Skip backing up existing configuration (use with caution).

### What It Does

#### 1. System Requirements Check
- ✅ Detects OS (Linux/macOS)
- ✅ Verifies Neovim >= 0.10.0
- ✅ Verifies Git installation
- ✅ Checks for Nerd Font

#### 2. Backup Existing Configuration
- Creates timestamped backup: `~/.config/nvim.backup-YYYYMMDD-HHMMSS`
- Preserves your old configuration safely
- Can be restored manually if needed

#### 3. Install Configuration
- Clones or copies configuration files to `~/.config/nvim`
- Preserves git history if available
- Sets up proper directory structure

#### 4. Dependency Management
Checks for and optionally installs:
- **ripgrep**: Fast text search (required for fuzzy finding)
- **fd**: Fast file finder (optional but recommended)
- **Node.js**: Required for many LSP servers
- **Python 3**: Required for Python LSP and some plugins
- **Rust**: Optional, for building performance-critical plugins

Supports package managers:
- **Linux**: pacman, apt, dnf, yum
- **macOS**: Homebrew

#### 5. Nerd Font Installation (Optional)
- Downloads JetBrainsMono Nerd Font
- Installs to `~/.local/share/fonts/`
- Updates font cache
- Provides instructions for terminal configuration

#### 6. Plugin Bootstrap
- Runs Neovim headless to install plugins
- Uses lazy.nvim plugin manager
- Installs all configured plugins automatically

#### 7. Post-Installation
- Creates necessary directories
- Displays next steps and useful commands
- Shows backup location if created

### Output Example

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║              🎉 Installation Complete! 🎉                    ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

✓ Neovim configuration installed successfully!

Next Steps:
  1. Start Neovim: nvim
  2. Wait for plugins to finish installing (if not done)
  3. Check health: :checkhealth
  4. Install LSP servers: :Mason

Useful Commands:
  :Lazy              - Plugin manager
  :Mason             - LSP installer
  :checkhealth       - Check system health
  <Space>ff          - Find files
  <Space>/           - Grep in project
```

### Troubleshooting

**"Neovim not found"**
- Install Neovim >= 0.10.0 first
- Linux: Check your distribution's package manager
- macOS: `brew install neovim`

**"Failed to download font"**
- Check internet connection
- Download manually from https://www.nerdfonts.com/
- Font installation is optional, script will continue

**"Permission denied"**
- Make script executable: `chmod +x install.sh`
- Some steps may require sudo (package installation)

**"Plugins failed to install"**
- Check internet connection
- Run `:Lazy sync` manually in Neovim
- Check `:checkhealth lazy` for issues

## uninstall.sh

### Overview

Automated uninstallation script that safely removes Neovim configuration with optional data cleanup.

### Usage

```bash
./uninstall.sh [OPTIONS]
```

### Options

| Option | Description |
|--------|-------------|
| (none) | Remove configuration only |
| `--full` | Remove everything (config + data + cache) |
| `--help` | Display help message |

### Examples

**Standard Uninstall (Config Only)**
```bash
./uninstall.sh
```
Removes `~/.config/nvim` but keeps plugin data and cache.

**Complete Removal**
```bash
./uninstall.sh --full
```
Removes everything:
- `~/.config/nvim` (configuration)
- `~/.local/share/nvim` (plugin data, Mason installations)
- `~/.local/state/nvim` (state files, history)
- `~/.cache/nvim` (cache files)

### What It Does

#### 1. Display Removal Plan
Shows what will be removed with file sizes:
```
The following will be removed:

  ✗ /home/user/.config/nvim (15M)
     Configuration files, plugins, and settings
  ✗ /home/user/.local/share/nvim (250M)
     Plugin data, Mason LSP servers, and local data
```

#### 2. Confirmation
Asks for confirmation before proceeding (default: No).
This prevents accidental deletions.

#### 3. Backup Option
Offers to create a backup before removal:
- Backup location: `~/.config/nvim.backup-YYYYMMDD-HHMMSS`
- Can be restored manually later
- Default: Yes (recommended)

#### 4. Removal
Safely removes directories:
- Validates paths before removal
- Shows progress for each step
- Confirms successful removal

#### 5. Completion Message
Displays:
- Success confirmation
- Backup location (if created)
- Restore instructions
- Reinstall command

### What Gets Removed

#### Standard Uninstall
```
~/.config/nvim/          # Configuration files
```

Keeps:
- Plugin data (for faster reinstall)
- LSP servers (no need to redownload)
- Cache (command history, etc.)

#### Full Uninstall (--full)
```
~/.config/nvim/          # Configuration files
~/.local/share/nvim/     # Plugin data, Mason installations
~/.local/state/nvim/     # State files (shada, etc.)
~/.cache/nvim/           # Cache files
```

Completely removes all Neovim-related files.

### Restore from Backup

If you created a backup, restore it:

```bash
# List backups
ls -la ~/.config/nvim.backup-*

# Restore specific backup
mv ~/.config/nvim.backup-20261217-103045 ~/.config/nvim
```

### Troubleshooting

**"No Neovim configuration found"**
- Configuration already removed or never installed
- Nothing to uninstall

**"Permission denied"**
- Make script executable: `chmod +x uninstall.sh`
- Check file ownership: `ls -la ~/.config/nvim`

**Want to keep some data?**
- Use standard uninstall (without `--full`)
- Manually backup specific directories before running

## Safety Features

Both scripts include:

### Error Handling
- `set -e`: Exit immediately on error
- Path validation before operations
- Existence checks before file operations

### User Confirmation
- Default to safe options (backup, no auto-delete)
- Clear prompts with [Y/n] or [y/N] defaults
- Can be bypassed with `--auto` (install.sh only)

### Backup Protection
- Timestamped backups prevent overwrites
- Automatic backup offers in both scripts
- Clear restore instructions provided

### Visual Feedback
- Color-coded messages (info, success, warning, error)
- Progress indicators
- Clear section headers
- File sizes shown before deletion

### Validation
- Checks system requirements
- Verifies installation before uninstall
- Shows exactly what will be affected

## Advanced Usage

### Scripted Installation (CI/CD)

```bash
#!/bin/bash
# Automated setup script

# Install dependencies first
sudo apt update
sudo apt install -y neovim git ripgrep fd-find nodejs

# Install Neovim config automatically
git clone https://github.com/user/nvim-config /tmp/nvim-config
cd /tmp/nvim-config
./install.sh --auto

# Verify installation
nvim --headless "+checkhealth" +qa
```

### Dotfiles Integration

```bash
# In your dotfiles install script
cd ~/.dotfiles/nvim
./install.sh --auto --skip-backup

# Or symlink approach
ln -sf ~/.dotfiles/nvim ~/.config/nvim
```

### Testing Multiple Configs

```bash
# Install to alternate location
export XDG_CONFIG_HOME=/tmp/test-config
./install.sh --auto

# Test the configuration
nvim

# Clean up
./uninstall.sh --full
```

### Migration Script

```bash
#!/bin/bash
# Migrate from old config to new

# Backup old config
./uninstall.sh  # Creates backup automatically

# Install new config
./install.sh --auto

# If issues, restore backup
# mv ~/.config/nvim.backup-TIMESTAMP ~/.config/nvim
```

## Environment Variables

Scripts respect XDG Base Directory specification:

| Variable | Default | Purpose |
|----------|---------|---------|
| `XDG_CONFIG_HOME` | `~/.config` | Configuration directory |
| `XDG_DATA_HOME` | `~/.local/share` | Data directory |
| `XDG_STATE_HOME` | `~/.local/state` | State directory |
| `XDG_CACHE_HOME` | `~/.cache` | Cache directory |

Override for custom locations:
```bash
export XDG_CONFIG_HOME=/custom/config
./install.sh
```

## Exit Codes

Both scripts use standard exit codes:

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error (missing requirements, failed operation) |

Use in scripts:
```bash
if ./install.sh --auto; then
    echo "Installation successful"
else
    echo "Installation failed"
    exit 1
fi
```

## Contributing

When modifying the scripts:

1. **Test thoroughly**: Test on clean VM/container
2. **Handle errors**: Add appropriate error checking
3. **User feedback**: Provide clear messages
4. **Documentation**: Update this file
5. **Compatibility**: Test on multiple distros/macOS

## License

Same as the main Neovim configuration (MIT).
