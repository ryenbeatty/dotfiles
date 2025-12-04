#!/usr/bin/env bash
#
# Install Node Version Manager (NVM) and latest LTS Node.js

set -euo pipefail

NVM_DIR="$HOME/.nvm"

# Install NVM if it doesn't exist
if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  echo "Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

  # Source NVM for this script
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
else
  echo "NVM is already installed"
  # Source NVM for this script
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# Install latest LTS Node.js if no version is installed
if ! nvm list | grep -q "node"; then
  echo "Installing latest LTS Node.js..."
  nvm install --lts
  nvm use --lts
  nvm alias default lts/*
else
  echo "Node.js is already installed via NVM"
fi

echo "NVM installation complete!"