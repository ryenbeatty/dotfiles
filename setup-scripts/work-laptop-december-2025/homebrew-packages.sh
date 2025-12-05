#!/usr/bin/env bash
#
# Comprehensive Homebrew package installation script
# Based on analysis of software installed on ryenbeatty's machine
#
# Usage: ./homebrew-packages.sh [--cli-only|--gui-only|--all]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check that Homebrew is available
check_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        error "Homebrew is not installed. Please run script/bootstrap first, which will install Homebrew."
        exit 1
    fi
    success "Homebrew found at $(command -v brew)"
}

# Install CLI tools and libraries
install_cli_tools() {
    info "Installing CLI tools and libraries..."

    # Essential tools that aren't included with macOS or installed as dependencies
    local cli_packages=(
        # Version control (git comes with Xcode tools, but Homebrew version is newer)
        "git"                  # Updated version of git
        "gh"                   # GitHub CLI

        # Text processing and search
        "ripgrep"              # Fast text search (replaces grep)
        "fzf"                  # Fuzzy finder
        "tree-sitter"          # Parser generator (needed for neovim)

        # System utilities
        "mas"                  # Mac App Store CLI
        "neofetch"            # System information
        "skhd"                # Hotkey daemon
        "yabai"               # Tiling window manager
        "tmux"                # Terminal multiplexer

        # Development languages and runtimes
        "node"                # JavaScript runtime
        "pyenv"               # Python version manager
        "neovim"              # Modern Vim

        # Package managers
        "pnpm"                # Fast Node.js package manager
        "uv"                  # Fast Python package manager

        # Media processing
        "youtube-dl"          # Video downloader
        "imagemagick"         # Image processing
        "ffmpeg"              # Video processing

        # Network and sync
        "syncthing"           # File synchronization

        # Security and encryption
        "gnupg"               # GPG encryption (includes pinentry as dependency)

        # Note: Removed packages that are either:
        # - Default on macOS: curl, zip, unzip, zsh, sqlite, python
        # - Dependencies of other packages: autoconf, automake, ca-certificates,
        #   fontconfig, freetype, gettext, glib, gmp, gnutls, icu4c@77,
        #   jpeg-turbo, libpng, libxml2, ncurses, openssl@3, pcre2,
        #   pkg-config, readline, brotli, lz4, zstd, lzo, pinentry
    )

    for package in "${cli_packages[@]}"; do
        if brew list --formula | grep -q "^${package}$"; then
            success "$package already installed"
        else
            info "Installing $package..."
            if brew install "$package"; then
                success "Installed $package"
            else
                error "Failed to install $package"
            fi
        fi
    done
}

# Install GUI applications via Homebrew Cask
install_gui_apps() {
    info "Installing GUI applications..."

    # Applications that are available via Homebrew Cask
    local cask_apps=(
        # Terminals
        "alacritty"           # Fast terminal emulator

        # Browsers
        "arc"                 # Modern web browser
        "brave-browser"       # Privacy-focused browser
        "firefox"             # Mozilla Firefox
        "google-chrome"       # Google Chrome
        "zen-browser"         # Privacy browser

        # Development
        "cursor"              # AI-powered code editor
        "github-desktop"      # GitHub GUI client
        "docker"              # Containerization
        "postman"             # API development
        "figma"               # Design tool
        "xcode"               # Apple development suite

        # Communication
        "discord"             # Voice and text chat
        "slack"               # Team communication
        "zoom"                # Video conferencing
        "loom"                # Screen recording

        # Productivity
        "notion"              # Note-taking and workspace
        "obsidian"            # Knowledge management
        "todoist"             # Task management
        "raycast"             # Launcher and productivity
        "cleanshot-x"         # Screenshot tool
        "the-unarchiver"      # Archive extraction
        "keepassxc"           # Password manager

        # Media and design
        "vlc"                 # Media player
        "gimp"                # Image editor
        "obs"                 # Streaming and recording
        "screen-studio"       # Screen recording

        # Utilities
        "hiddenbar"           # Menu bar management
        "dockey"             # Dock customization
        "granola"            # Sleep prevention
        "steermouse"         # Advanced mouse control
        "topnotch"           # Notch hider for MacBooks
        "cold-turkey-blocker" # Website blocker
        "karabiner-elements" # Key mapping
        "logitech-options-plus" # Logitech device manager

        # VPN and Security
        "protonvpn"          # Secure VPN

        # Entertainment
        "steam"              # Gaming platform

        # Audio production (some available via cask)
        "zed"                # Fast code editor
        "emacs"              # Emacs editor
    )

    for app in "${cask_apps[@]}"; do
        if brew list --cask | grep -q "^${app}$"; then
            success "$app already installed"
        else
            info "Installing $app..."
            if brew install --cask "$app"; then
                success "Installed $app"
            else
                warning "Failed to install $app (might not be available or require manual installation)"
            fi
        fi
    done
}

# Install global npm packages
install_npm_packages() {
    info "Installing global npm packages..."

    if ! command -v npm >/dev/null 2>&1; then
        warning "npm not found. Skipping npm packages."
        return 1
    fi

    local npm_packages=(
        "@anthropic-ai/claude-code"
    )

    for package in "${npm_packages[@]}"; do
        if npm list -g "$package" >/dev/null 2>&1; then
            success "$package already installed globally"
        else
            info "Installing $package..."
            if npm install -g "$package"; then
                success "Installed $package"
            else
                warning "Failed to install $package"
            fi
        fi
    done
}

# List apps that need manual installation
list_manual_installs() {
    info "Applications that require manual installation:"

    cat << 'EOF'
🔧 MANUAL INSTALLATION REQUIRED:

Design & 3D:
  • Origami Studio - https://origami.design/
  • ProtoPie - https://www.protopie.io/
  • Miro - https://miro.com/

Other Tools:
  • ChatGPT - https://openai.com/chatgpt/mac/
  • Claude - https://claude.ai/
  • Perplexity AI - https://www.perplexity.ai/
  • Warp - https://www.warp.dev/
  • Beat - (Check Mac App Store)
  • dictop - (Check availability)
  • GPG Keychain - https://gpgtools.org/
  • Google Earth Pro - https://www.google.com/earth/versions/
  • Highland 2 - (Check Mac App Store)
  • iLok License Manager - https://www.ilok.com/
  • KeyFinder - (Check availability)
  • LookAway - (Check availability)
  • Mp3tag - https://mp3tag.app/
  • MusicBrainz Picard - https://picard.musicbrainz.org/
  • OmniDiskSweeper - https://www.omnigroup.com/more
  • Rayon - (Check availability)
  • Sononym - https://www.sononym.net/
  • SonoBus - https://sonobus.net/
  • superwhisper - (Check availability)
  • XLD - https://tmkk.undo.jp/xld/index_e.html

Note: Some of these may become available via Homebrew Cask in the future.
Check periodically with: brew search [app-name]
EOF
}

# Main function
main() {
    local install_type="${1:-}"

    echo "🍺 Homebrew Package Installation Script"
    echo "======================================"

    check_homebrew

    case "$install_type" in
        --cli-only)
            install_cli_tools
            install_npm_packages
            ;;
        --gui-only)
            install_gui_apps
            install_mas_apps
            ;;
        --all|"")
            install_cli_tools
            install_gui_apps
            install_mas_apps
            install_npm_packages
            list_manual_installs
            ;;
        *)
            error "Invalid option: $install_type"
            echo "Usage: $0 [--cli-only|--gui-only|--all]"
            exit 1
            ;;
    esac

    success "Installation complete!"
    info "Run 'brew upgrade' periodically to keep packages up to date."
}

# Run main function with all arguments
main "$@"