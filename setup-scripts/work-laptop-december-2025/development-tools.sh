#!/usr/bin/env bash
#
# Development tools installation script
# Installs programming languages, tools, and development environments

set -euo pipefail

info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

# Install Homebrew if not already installed
install_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        info "Homebrew not found. Installing Homebrew..."

        # Download and run the official Homebrew installation script
        if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            success "Homebrew installed successfully"

            # Add Homebrew to PATH for the current session
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                # Apple Silicon Mac
                eval "$(/opt/homebrew/bin/brew shellenv)"
                info "Added Homebrew to PATH (Apple Silicon)"
            elif [[ -f "/usr/local/bin/brew" ]]; then
                # Intel Mac
                eval "$(/usr/local/bin/brew shellenv)"
                info "Added Homebrew to PATH (Intel)"
            fi

            # Verify installation
            if command -v brew >/dev/null 2>&1; then
                success "Homebrew is now available at $(command -v brew)"
            else
                error "Homebrew installation completed but 'brew' command not found in PATH"
                error "You may need to restart your terminal"
            fi
        else
            error "Failed to install Homebrew automatically"
            info "Some development tools require Homebrew and may fail to install"
        fi
    fi
}

# Install Node.js via NVM
install_nodejs() {
    info "Setting up Node.js via NVM..."

    # Install NVM if not already installed
    if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
        info "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    fi

    # Source NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Install latest LTS Node.js
    if command -v nvm >/dev/null 2>&1; then
        info "Installing latest LTS Node.js..."
        nvm install --lts
        nvm use --lts
        nvm alias default lts/*
        success "Node.js installed via NVM"
    else
        error "Failed to install NVM"
    fi
}

# Install Python development tools
install_python_tools() {
    info "Setting up Python development environment..."

    # Install pyenv if not already installed
    if ! command -v pyenv >/dev/null 2>&1; then
        if command -v brew >/dev/null 2>&1; then
            info "Installing pyenv via Homebrew..."
            brew install pyenv
        else
            info "Installing pyenv via curl..."
            curl https://pyenv.run | bash
        fi

        # Add pyenv to PATH for this session immediately after installation
        export PATH="$HOME/.pyenv/bin:$PATH"
        eval "$(pyenv init --path)" 2>/dev/null || true
        eval "$(pyenv init -)" 2>/dev/null || true
    fi

    # Install latest Python versions
    if command -v pyenv >/dev/null 2>&1; then
        info "Installing Python 3.12..."

        # Add pyenv to PATH for this session
        export PATH="$HOME/.pyenv/bin:$PATH"
        eval "$(pyenv init --path)" 2>/dev/null || true
        eval "$(pyenv init -)" 2>/dev/null || true

        # Install Python 3.12 if not already installed
        if ! pyenv versions | grep -q "3.12.7"; then
            pyenv install 3.12.7
        fi
        pyenv global 3.12.7

        # Refresh pyenv shims
        pyenv rehash

        # Install essential Python packages using pyenv's Python
        if command -v pip >/dev/null 2>&1; then
            info "Installing Python packages..."
            pip install --upgrade pip
            pip install uv  # Fast package manager
            success "Python packages installed"
        else
            warning "pip not available after pyenv setup, skipping Python packages"
        fi

        success "Python development environment configured"
    else
        warning "pyenv not available, skipping Python setup"
    fi
}

# Install Bun (fast JavaScript runtime)
install_bun() {
    info "Installing Bun..."

    if ! command -v bun >/dev/null 2>&1; then
        curl -fsSL https://bun.sh/install | bash
        success "Bun installed"
    else
        success "Bun already installed"
    fi
}

# Install Rust development tools
install_rust() {
    info "Installing Rust development tools..."

    if ! command -v rustc >/dev/null 2>&1; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        success "Rust installed"
    else
        success "Rust already installed"
    fi
}

# Install Go programming language
install_go() {
    info "Installing Go..."

    if command -v brew >/dev/null 2>&1; then
        if ! brew list | grep -q "^go$"; then
            brew install go
            success "Go installed via Homebrew"
        else
            success "Go already installed"
        fi
    else
        error "Homebrew not found, please install Go manually"
    fi
}

# Install Java development kit
install_java() {
    info "Installing Java..."

    if command -v brew >/dev/null 2>&1; then
        if ! brew list --cask | grep -q "temurin"; then
            brew install --cask temurin
            success "Java (Temurin) installed"
        else
            success "Java already installed"
        fi
    fi
}

# Install development databases
install_databases() {
    info "Installing development databases..."

    if command -v brew >/dev/null 2>&1; then
        local dbs=("postgresql" "redis" "sqlite")

        for db in "${dbs[@]}"; do
            if ! brew list | grep -q "^${db}$"; then
                brew install "$db"
                success "$db installed"
            else
                success "$db already installed"
            fi
        done
    fi
}

# Install global npm/bun packages for development
install_global_packages() {
    info "Installing global development packages..."

    local packages=(
        "typescript"
        "ts-node"
        "@types/node"
        "eslint"
        "prettier"
        "nodemon"
        "concurrently"
        "http-server"
        "serve"
    )

    if command -v npm >/dev/null 2>&1; then
        for package in "${packages[@]}"; do
            if ! npm list -g "$package" >/dev/null 2>&1; then
                npm install -g "$package"
                success "Installed $package"
            fi
        done
    fi
}

# Main execution
main() {
    echo "🛠️  Development Tools Installation"
    echo "=================================="

    install_homebrew
    install_nodejs
    install_python_tools
    install_bun
    install_rust
    install_go
    install_java
    install_databases
    install_global_packages

    success "Development environment setup complete!"
    echo ""
    echo "Don't forget to:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Check versions: node --version, python --version, go version, etc."
}

main "$@"