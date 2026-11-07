#!/usr/bin/env bash
#
# Install/refresh the neovim plugins, language servers, formatters and
# tree-sitter parsers. Run by `script/install` (i.e. by `dot`), or directly.
#
#   ./nvim/install.sh            # plugins + servers + parsers
#   ./nvim/install.sh --plugins  # plugins only, no downloads
#
set -euo pipefail

if ! command -v nvim >/dev/null 2>&1; then
  echo "nvim not installed, skipping"
  exit 0
fi

# Plugins first: sync installs everything and runs each plugin's build step,
# which for nvim-treesitter is `:TSUpdate` (parsers).
echo "› syncing plugins (lazy.nvim)"
nvim --headless "+Lazy! sync" +qa

if [[ ${1:-} == "--plugins" ]]; then
  exit 0
fi

# In a headless session nothing has triggered the lazy-load events, so the
# plugins that define the commands below must be loaded explicitly first.
# `MasonToolsInstallSync` (not MasonInstall) is used because it blocks until
# every package is in place, so the treesitter step can rely on the result.
echo "› installing language servers and formatters (mason)"
nvim --headless "+Lazy! load mason-tool-installer.nvim" "+MasonToolsInstallSync" +qa

echo "› installing tree-sitter parsers"
nvim --headless "+Lazy! load nvim-treesitter" "+TSUpdateSync" +qa

echo "› done"
