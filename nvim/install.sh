#!/usr/bin/env bash
#
# Install/refresh the neovim plugins, language servers, formatters and
# tree-sitter parsers. Run by `script/install` (i.e. by `dot`), or directly.
#
#   ./nvim/install.sh            # sync plugins + servers + parsers
#   ./nvim/install.sh --plugins  # plugins only, no downloads
#
set -euo pipefail

if ! command -v nvim >/dev/null 2>&1; then
  echo "nvim not installed, skipping"
  exit 0
fi

LSP_SERVERS=(
  lua-language-server
  typescript-language-server
  vscode-langservers-extracted
  yaml-language-server
  eslint-lsp
)

TOOLS=(
  stylua
  prettier
  eslint_d
)

echo "› syncing plugins (lazy.nvim)"
nvim --headless "+Lazy! sync" +qa

if [[ ${1:-} == "--plugins" ]]; then
  exit 0
fi

echo "› installing language servers and formatters (mason)"
nvim --headless "+MasonInstall ${LSP_SERVERS[*]} ${TOOLS[*]}" +qa

echo "› installing tree-sitter parsers"
nvim --headless "+TSUpdateSync" +qa

echo "› done"
