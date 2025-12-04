#!/usr/bin/env bash
#
# Install Bun JavaScript runtime

set -euo pipefail

# Install Bun if it doesn't exist
if ! command -v bun >/dev/null 2>&1; then
  echo "Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
else
  echo "Bun is already installed"
fi

echo "Bun installation complete!"