#!/usr/bin/env bash
#
# Install Homebrew and essential packages

set -euo pipefail

# Check if we're on macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Homebrew installation is only supported on macOS"
  exit 0
fi

# Install Homebrew if it doesn't exist
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for the rest of the script
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    # Apple Silicon Mac
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    # Intel Mac
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "Homebrew is already installed"
fi

# Update Homebrew
echo "Updating Homebrew..."
brew update

# Install essential packages
echo "Installing essential packages..."
brew install --quiet \
  fzf \
  ripgrep \
  git \
  nvim \
  tmux \
  tree \
  wget \
  curl \
  jq \
  gh \
  grc \
  coreutils \
  yabai \
  skhd

# Install GUI applications
echo "Installing GUI applications..."
brew install --cask --quiet \
  alacritty \
  visual-studio-code

echo "Homebrew installation complete!"