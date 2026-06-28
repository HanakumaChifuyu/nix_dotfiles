#!/usr/bin/env bash

# ============================================================================
# Neovim Configuration Installer
# ============================================================================
# This script automates the installation of this Neovim configuration
# including all dependencies and optional tools.
#
# Usage:
#   ./install.sh              # Interactive installation
#   ./install.sh --auto       # Automatic installation (skip confirmations)
#   ./install.sh --help       # Show help message
# ============================================================================

set -e  # Exit on error

# ============================================================================
# Color Output
# ============================================================================

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    BOLD=''
    RESET=''
fi

# ============================================================================
# Utility Functions
# ============================================================================

log_info() {
    echo -e "${BLUE}ℹ${RESET} $1"
}

log_success() {
    echo -e "${GREEN}✓${RESET} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${RESET} $1"
}

log_error() {
    echo -e "${RED}✗${RESET} $1"
}

log_step() {
    echo -e "\n${CYAN}${BOLD}▶${RESET} ${BOLD}$1${RESET}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

ask_confirmation() {
    if [[ "$AUTO_MODE" == "true" ]]; then
        return 0
    fi

    local question="$1"
    local default="${2:-y}"

    if [[ "$default" == "y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi

    while true; do
        read -rp "$(echo -e "${YELLOW}?${RESET} $question $prompt: ")" answer
        answer=${answer:-$default}

        case ${answer:0:1} in
            y|Y) return 0 ;;
            n|N) return 1 ;;
            *) echo "Please answer yes or no." ;;
        esac
    done
}

# ============================================================================
# Parse Arguments
# ============================================================================

AUTO_MODE=false
SKIP_BACKUP=false

show_help() {
    printf "%bNeovim Configuration Installer%b\n\n" "${BOLD}" "${RESET}"
    printf "%bUSAGE:%b\n" "${BOLD}" "${RESET}"
    printf "    %s [OPTIONS]\n\n" "$0"
    printf "%bOPTIONS:%b\n" "${BOLD}" "${RESET}"
    printf "    --auto              Skip all confirmations (automatic mode)\n"
    printf "    --skip-backup       Skip backing up existing configuration\n"
    printf "    --help              Show this help message\n\n"
    printf "%bEXAMPLES:%b\n" "${BOLD}" "${RESET}"
    printf "    %s                  Interactive installation\n" "$0"
    printf "    %s --auto           Fully automatic installation\n" "$0"
    printf "    %s --skip-backup    Install without backing up\n\n" "$0"
    printf "%bWHAT THIS SCRIPT DOES:%b\n" "${BOLD}" "${RESET}"
    printf "    1. Check system requirements (Neovim, Git, etc.)\n"
    printf "    2. Backup existing Neovim configuration\n"
    printf "    3. Install this configuration\n"
    printf "    4. Check and install optional dependencies (ripgrep, fd, etc.)\n"
    printf "    5. Install Nerd Font (optional)\n"
    printf "    6. Bootstrap lazy.nvim plugin manager\n\n"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            AUTO_MODE=true
            shift
            ;;
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --help|-h)
            show_help
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help to see available options"
            exit 1
            ;;
    esac
done

# ============================================================================
# Welcome Message
# ============================================================================

clear
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║     ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗      ║
║     ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║      ║
║     ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║      ║
║     ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║      ║
║     ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║      ║
║     ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝      ║
║                                                               ║
║           Configuration Installer v1.0                        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF

echo ""
log_info "This script will install a modern Neovim configuration"
log_info "with LSP support, completion, fuzzy finding, and more!"
echo ""

if [[ "$AUTO_MODE" == "false" ]]; then
    if ! ask_confirmation "Do you want to continue?"; then
        log_info "Installation cancelled."
        exit 0
    fi
fi

# ============================================================================
# Check System Requirements
# ============================================================================

log_step "Checking system requirements..."

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    log_error "Unsupported OS: $OSTYPE"
    exit 1
fi
log_success "Operating System: $OS"

# Check Neovim
if command_exists nvim; then
    NVIM_VERSION=$(nvim --version | head -n 1 | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
    log_success "Neovim found: v$NVIM_VERSION"

    # Check minimum version (0.10.0)
    if ! printf '%s\n' "0.10.0" "$NVIM_VERSION" | sort -V -C; then
        log_warning "Neovim version $NVIM_VERSION is older than 0.10.0"
        log_info "Some features may not work. Consider upgrading Neovim."
    fi
else
    log_error "Neovim is not installed!"
    log_info "Please install Neovim >= 0.10.0 first:"
    if [[ "$OS" == "linux" ]]; then
        echo "  - Arch Linux: sudo pacman -S neovim"
        echo "  - Ubuntu/Debian: Check https://github.com/neovim/neovim/releases"
        echo "  - Fedora: sudo dnf install neovim"
    else
        echo "  - macOS: brew install neovim"
    fi
    exit 1
fi

# Check Git
if command_exists git; then
    GIT_VERSION=$(git --version | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
    log_success "Git found: v$GIT_VERSION"
else
    log_error "Git is not installed!"
    log_info "Please install Git first."
    exit 1
fi

# Check for Nerd Font
log_info "Checking for Nerd Font..."
if fc-list | grep -qi "nerd"; then
    log_success "Nerd Font detected"
    NERD_FONT_INSTALLED=true
else
    log_warning "No Nerd Font detected"
    log_info "Icons may not display correctly without a Nerd Font"
    NERD_FONT_INSTALLED=false
fi

# ============================================================================
# Backup Existing Configuration
# ============================================================================

NVIM_CONFIG_DIR="$HOME/.config/nvim"
BACKUP_DIR="$HOME/.config/nvim.backup-$(date +%Y%m%d-%H%M%S)"

if [[ -d "$NVIM_CONFIG_DIR" ]] && [[ "$SKIP_BACKUP" == "false" ]]; then
    log_step "Backing up existing configuration..."

    if ask_confirmation "Existing Neovim config found. Create backup?"; then
        mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
        log_success "Backup created at: $BACKUP_DIR"
    else
        log_warning "Skipping backup. Existing config will be overwritten!"
        rm -rf "$NVIM_CONFIG_DIR"
    fi
fi

# ============================================================================
# Install Configuration
# ============================================================================

log_step "Installing Neovim configuration..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$SCRIPT_DIR" == "$NVIM_CONFIG_DIR" ]]; then
    log_success "Already in correct location: $NVIM_CONFIG_DIR"
else
    # Check if we're in a git repo
    if [[ -d "$SCRIPT_DIR/.git" ]]; then
        log_info "Git repository detected. Cloning to $NVIM_CONFIG_DIR..."

        # Get the remote URL
        REMOTE_URL=$(cd "$SCRIPT_DIR" && git config --get remote.origin.url)

        if [[ -n "$REMOTE_URL" ]]; then
            git clone "$REMOTE_URL" "$NVIM_CONFIG_DIR"
        else
            log_warning "No remote URL found. Copying files instead..."
            mkdir -p "$NVIM_CONFIG_DIR"
            cp -r "$SCRIPT_DIR"/* "$NVIM_CONFIG_DIR"/
        fi
    else
        log_info "Copying configuration files to $NVIM_CONFIG_DIR..."
        mkdir -p "$NVIM_CONFIG_DIR"
        cp -r "$SCRIPT_DIR"/* "$NVIM_CONFIG_DIR"/
    fi

    log_success "Configuration installed successfully"
fi

# ============================================================================
# Check and Install Dependencies
# ============================================================================

log_step "Checking optional dependencies..."

declare -A DEPENDENCIES=(
    ["ripgrep"]="Fast grep alternative (required for fuzzy finding)"
    ["fd"]="Fast find alternative (optional, improves file finding)"
    ["node"]="JavaScript runtime (required for some LSP servers)"
    ["python3"]="Python 3 (required for some LSP servers)"
    ["cargo"]="Rust toolchain (optional, for building some plugins)"
)

MISSING_DEPS=()

for dep in "${!DEPENDENCIES[@]}"; do
    if command_exists "$dep"; then
        log_success "$dep: installed"
    else
        log_warning "$dep: not found - ${DEPENDENCIES[$dep]}"
        MISSING_DEPS+=("$dep")
    fi
done

if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
    echo ""
    log_info "Missing dependencies detected: ${MISSING_DEPS[*]}"

    if ask_confirmation "Would you like to install missing dependencies?"; then
        install_dependencies() {
            if [[ "$OS" == "linux" ]]; then
                # Detect package manager
                if command_exists pacman; then
                    log_info "Using pacman..."
                    sudo pacman -S --needed ripgrep fd nodejs python python-pip rust
                elif command_exists apt; then
                    log_info "Using apt..."
                    sudo apt update
                    sudo apt install -y ripgrep fd-find nodejs python3 python3-pip cargo
                elif command_exists dnf; then
                    log_info "Using dnf..."
                    sudo dnf install -y ripgrep fd-find nodejs python3 python3-pip cargo
                elif command_exists yum; then
                    log_info "Using yum..."
                    sudo yum install -y ripgrep fd-find nodejs python3 python3-pip cargo
                else
                    log_error "No supported package manager found"
                    log_info "Please install dependencies manually"
                    return 1
                fi
            elif [[ "$OS" == "macos" ]]; then
                if command_exists brew; then
                    log_info "Using Homebrew..."
                    brew install ripgrep fd node python rust
                else
                    log_error "Homebrew not found"
                    log_info "Install Homebrew: https://brew.sh"
                    return 1
                fi
            fi

            log_success "Dependencies installed"
        }

        install_dependencies
    fi
fi

# ============================================================================
# Nerd Font Installation
# ============================================================================

if [[ "$NERD_FONT_INSTALLED" == "false" ]]; then
    echo ""
    log_step "Nerd Font Installation"

    if ask_confirmation "Would you like to install a Nerd Font?"; then
        FONTS_DIR="$HOME/.local/share/fonts"
        mkdir -p "$FONTS_DIR"

        log_info "Downloading JetBrainsMono Nerd Font..."
        FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
        TEMP_DIR=$(mktemp -d)

        if curl -fLo "$TEMP_DIR/JetBrainsMono.zip" "$FONT_URL"; then
            log_info "Extracting font..."
            unzip -q "$TEMP_DIR/JetBrainsMono.zip" -d "$FONTS_DIR/JetBrainsMono"

            log_info "Updating font cache..."
            if command_exists fc-cache; then
                fc-cache -fv "$FONTS_DIR" >/dev/null 2>&1
            fi

            rm -rf "$TEMP_DIR"
            log_success "JetBrainsMono Nerd Font installed"
            log_info "Please set your terminal font to 'JetBrainsMono Nerd Font'"
        else
            log_error "Failed to download font"
            log_info "You can manually download from: https://www.nerdfonts.com/"
        fi
    fi
fi

# ============================================================================
# Bootstrap Lazy.nvim
# ============================================================================

log_step "Bootstrapping lazy.nvim plugin manager..."

log_info "This will start Neovim and install all plugins..."
log_info "This may take a few minutes on first run."
echo ""

if ask_confirmation "Start Neovim to install plugins?"; then
    # Run Neovim headless to install plugins
    nvim --headless "+Lazy! sync" +qa

    log_success "Plugins installed successfully"
else
    log_warning "Skipping plugin installation"
    log_info "Run :Lazy sync in Neovim to install plugins manually"
fi

# ============================================================================
# Post-Installation Steps
# ============================================================================

log_step "Post-installation setup..."

# Create necessary directories
mkdir -p "$HOME/.local/share/nvim"
mkdir -p "$HOME/.local/state/nvim"

log_success "Directories created"

# ============================================================================
# Installation Complete
# ============================================================================

echo ""
echo -e "${GREEN}${BOLD}╔═══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║                                                               ║${RESET}"
echo -e "${GREEN}${BOLD}║              🎉 Installation Complete! 🎉                    ║${RESET}"
echo -e "${GREEN}${BOLD}║                                                               ║${RESET}"
echo -e "${GREEN}${BOLD}╚═══════════════════════════════════════════════════════════════╝${RESET}"
echo ""

log_success "Neovim configuration installed successfully!"
echo ""

log_info "${BOLD}Next Steps:${RESET}"
echo "  1. Start Neovim: nvim"
echo "  2. Wait for plugins to finish installing (if not done)"
echo "  3. Check health: :checkhealth"
echo "  4. Install LSP servers: :Mason"
echo ""

if [[ "$NERD_FONT_INSTALLED" == "false" ]]; then
    log_warning "Remember to set your terminal font to a Nerd Font for icons!"
fi

if [[ -d "$BACKUP_DIR" ]]; then
    log_info "Your old config was backed up to:"
    echo "  $BACKUP_DIR"
    echo ""
fi

log_info "${BOLD}Useful Commands:${RESET}"
echo "  :Lazy              - Plugin manager"
echo "  :Mason             - LSP installer"
echo "  :checkhealth       - Check system health"
echo "  :help              - Open help documentation"
echo "  <Space>ff          - Find files"
echo "  <Space>/           - Grep in project"
echo ""

log_info "${BOLD}Documentation:${RESET}"
echo "  README.md          - Main documentation"
echo "  docs/              - Additional guides"
echo ""

log_success "Happy coding! 🚀"
echo ""

exit 0
