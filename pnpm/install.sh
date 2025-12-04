#!/usr/bin/env bash
#
# Install pnpm package manager

set -euo pipefail

# Install pnpm if it doesn't exist
if ! command -v pnpm >/dev/null 2>&1; then
  echo "Installing pnpm..."
  curl -fsSL https://get.pnpm.io/install.sh | sh -
else
  echo "pnpm is already installed"
fi

echo "pnpm installation complete!"