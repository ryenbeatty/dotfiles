#!/usr/bin/env bash
#
# Install Python development tools

set -euo pipefail

# Install pyenv if it doesn't exist and we're on macOS
if ! command -v pyenv >/dev/null 2>&1; then
  if [[ "$(uname -s)" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
    echo "Installing pyenv..."
    brew install pyenv
  else
    echo "Installing pyenv via curl..."
    curl https://pyenv.run | bash
  fi
else
  echo "pyenv is already installed"
fi

echo "Python tools installation complete!"