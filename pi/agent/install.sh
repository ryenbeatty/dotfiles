#!/usr/bin/env bash
#
# pi/agent/install.sh -- dependencies for the tracked pi config.
#
# Run by `script/install`, which finds every install.sh in the repo. Safe to
# re-run; each step is a no-op once it has succeeded. Operates on the repo
# paths directly (not ~/.pi/agent), so it works whether or not bootstrap has
# symlinked them yet.
set -euo pipefail

ROOT="${DOTFILES_ROOT:-$HOME/.dotfiles}"

npm_install () {
  local dir=$1
  [ -f "$dir/package.json" ] || return 0
  echo "  pi: npm install ($dir)"
  ( cd "$dir" && npm install --silent --no-fund --no-audit )
}

npm_install "$ROOT/pi/agent/extensions/browser"
npm_install "$ROOT/pi/agent/npm"
npm_install "$ROOT/pi/agent/mcp-servers/agentation-mcp"

# The browser_* tools launch headless chromium via playwright-core, which
# ships without browser binaries. One-time ~150MB download.
if [ -f "$ROOT/pi/agent/extensions/browser/package.json" ]; then
  if ! compgen -G "$HOME/Library/Caches/ms-playwright/chromium-*" >/dev/null; then
    echo "  pi: installing chromium for the browser tools (~150MB, one-time)"
    ( cd "$ROOT/pi/agent/extensions/browser" && npx --yes playwright install chromium )
  else
    echo "  pi: chromium already installed"
  fi
fi
