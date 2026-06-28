#!/usr/bin/env bash

# ============================================================================
# Neovim Configuration Uninstaller
# ============================================================================
# This script removes the Neovim configuration and optionally cleans up
# associated data, cache, and plugin files.
#
# Usage:
#   ./uninstall.sh              # Interactive uninstallation
#   ./uninstall.sh --full       # Remove everything including data/cache
#   ./uninstall.sh --help       # Show help message
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
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
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

ask_confirmation() {
    local question="$1"
    local default="${2:-n}"

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

FULL_UNINSTALL=false

show_help() {
    printf "%bNeovim Configuration Uninstaller%b\n\n" "${BOLD}" "${RESET}"
    printf "%bUSAGE:%b\n" "${BOLD}" "${RESET}"
    printf "    %s [OPTIONS]\n\n" "$0"
    printf "%bOPTIONS:%b\n" "${BOLD}" "${RESET}"
    printf "    --full              Remove everything (config, data, cache, state)\n"
    printf "    --help              Show this help message\n\n"
    printf "%bEXAMPLES:%b\n" "${BOLD}" "${RESET}"
    printf "    %s                  Interactive uninstallation (config only)\n" "$0"
    printf "    %s --full           Complete removal (config + data + cache)\n\n" "$0"
    printf "%bWHAT GETS REMOVED:%b\n\n" "${BOLD}" "${RESET}"
    printf "%bStandard Uninstall:%b\n" "${BOLD}" "${RESET}"
    printf "    ~/.config/nvim      Configuration files\n\n"
    printf "%bFull Uninstall (--full):%b\n" "${BOLD}" "${RESET}"
    printf "    ~/.config/nvim      Configuration files\n"
    printf "    ~/.local/share/nvim Plugin data and Mason installations\n"
    printf "    ~/.local/state/nvim State files (shada, etc.)\n"
    printf "    ~/.cache/nvim       Cache files\n\n"
    printf "%bBACKUPS:%b\n" "${BOLD}" "${RESET}"
    printf "    Before removal, you'll be offered to create a backup.\n"
    printf "    Backups are saved to ~/.config/nvim.backup-TIMESTAMP\n\n"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --full)
            FULL_UNINSTALL=true
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
║           Configuration Uninstaller v1.0                      ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF

echo ""
log_warning "${BOLD}This script will remove your Neovim configuration${RESET}"
echo ""

# ============================================================================
# Show What Will Be Removed
# ============================================================================

NVIM_CONFIG_DIR="$HOME/.config/nvim"
NVIM_DATA_DIR="$HOME/.local/share/nvim"
NVIM_STATE_DIR="$HOME/.local/state/nvim"
NVIM_CACHE_DIR="$HOME/.cache/nvim"

log_step "The following will be removed:"
echo ""

check_and_display() {
    local path="$1"
    local description="$2"

    if [[ -e "$path" ]]; then
        local size=$(du -sh "$path" 2>/dev/null | cut -f1)
        echo -e "  ${RED}✗${RESET} $path ${BLUE}($size)${RESET}"
        echo -e "     $description"
        return 0
    else
        echo -e "  ${YELLOW}-${RESET} $path ${YELLOW}(not found)${RESET}"
        return 1
    fi
}

FOUND_FILES=false

if check_and_display "$NVIM_CONFIG_DIR" "Configuration files, plugins, and settings"; then
    FOUND_FILES=true
fi

if [[ "$FULL_UNINSTALL" == "true" ]]; then
    if check_and_display "$NVIM_DATA_DIR" "Plugin data, Mason LSP servers, and local data"; then
        FOUND_FILES=true
    fi

    if check_and_display "$NVIM_STATE_DIR" "State files (command history, etc.)"; then
        FOUND_FILES=true
    fi

    if check_and_display "$NVIM_CACHE_DIR" "Cache files"; then
        FOUND_FILES=true
    fi
fi

echo ""

if [[ "$FOUND_FILES" == "false" ]]; then
    log_info "No Neovim configuration found. Nothing to uninstall."
    exit 0
fi

# ============================================================================
# Confirmation
# ============================================================================

if ! ask_confirmation "${BOLD}Are you sure you want to proceed?${RESET}" "n"; then
    log_info "Uninstallation cancelled."
    exit 0
fi

# ============================================================================
# Backup Option
# ============================================================================

BACKUP_DIR="$HOME/.config/nvim.backup-$(date +%Y%m%d-%H%M%S)"

echo ""
if [[ -d "$NVIM_CONFIG_DIR" ]]; then
    if ask_confirmation "Would you like to create a backup before removal?" "y"; then
        log_step "Creating backup..."
        cp -r "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
        log_success "Backup created at: $BACKUP_DIR"
    fi
fi

# ============================================================================
# Removal
# ============================================================================

log_step "Removing Neovim configuration..."

remove_if_exists() {
    local path="$1"
    local description="$2"

    if [[ -e "$path" ]]; then
        log_info "Removing $description..."
        rm -rf "$path"
        log_success "Removed: $path"
    fi
}

# Always remove config
remove_if_exists "$NVIM_CONFIG_DIR" "configuration files"

# Remove data/cache/state if full uninstall
if [[ "$FULL_UNINSTALL" == "true" ]]; then
    remove_if_exists "$NVIM_DATA_DIR" "data files"
    remove_if_exists "$NVIM_STATE_DIR" "state files"
    remove_if_exists "$NVIM_CACHE_DIR" "cache files"
fi

# ============================================================================
# Completion Message
# ============================================================================

echo ""
echo -e "${GREEN}${BOLD}╔═══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║                                                               ║${RESET}"
echo -e "${GREEN}${BOLD}║           ✓ Uninstallation Complete                          ║${RESET}"
echo -e "${GREEN}${BOLD}║                                                               ║${RESET}"
echo -e "${GREEN}${BOLD}╚═══════════════════════════════════════════════════════════════╝${RESET}"
echo ""

log_success "Neovim configuration has been removed successfully"
echo ""

if [[ -d "$BACKUP_DIR" ]]; then
    log_info "Your configuration was backed up to:"
    echo "  $BACKUP_DIR"
    echo ""
    log_info "To restore your configuration:"
    echo "  mv $BACKUP_DIR $NVIM_CONFIG_DIR"
    echo ""
fi

if [[ "$FULL_UNINSTALL" == "false" ]]; then
    log_info "${YELLOW}Note:${RESET} Plugin data and cache were not removed."
    log_info "Run with --full to remove everything:"
    echo "  $0 --full"
    echo ""
fi

log_info "To reinstall, run:"
echo "  ./install.sh"
echo ""

exit 0
