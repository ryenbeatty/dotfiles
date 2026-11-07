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

# nvim exits 0 even when a :command callback throws, so prove the install
# actually produced binaries instead of trusting the exit code.
missing=0
for bin in lua-language-server typescript-language-server \
           vscode-html-language-server vscode-css-language-server \
           vscode-json-language-server vscode-eslint-language-server \
           yaml-language-server stylua prettier eslint_d; do
  [[ -x $HOME/.local/share/nvim/mason/bin/$bin ]] || { echo "  missing: $bin"; missing=1; }
done
if (( missing )); then
  echo "mason install incomplete -- open nvim and check :Mason" >&2
  exit 1
fi

echo "› installing tree-sitter parsers"
nvim --headless "+Lazy! load nvim-treesitter" "+TSUpdateSync" +qa

echo "› done"
