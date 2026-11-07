#!/usr/bin/env bash
#
# Converge the Python toolchain: uv itself, then every interpreter listed in
# pythons.txt and every CLI listed in tools.txt.
#
# No shell hook is needed. uv's binaries live in ~/.local/bin, which
# system/_path.zsh already puts on PATH, so there is nothing to `eval` at
# startup -- that is the ~100ms the old `pyenv init -` cost.
#
set -euo pipefail

TOPIC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------- 1. uv
# Installed via Homebrew on purpose: the standalone installer writes
# ~/.config/uv/uv-receipt.json, and that directory is a symlink into this repo,
# so `uv self update` would dirty the working tree.
if ! command -v uv >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    echo "› installing uv (brew)"
    brew install --quiet uv
  else
    echo "uv is missing and Homebrew is not available; install uv manually" >&2
    exit 1
  fi
fi

# ------------------------------------------------------- 2. interpreters
if [[ -f $TOPIC_DIR/pythons.txt ]]; then
  while read -r version; do
    [[ -z $version || $version == \#* ]] && continue
    echo "› uv python install $version"
    uv python install "$version"
  done < "$TOPIC_DIR/pythons.txt"
fi

# ------------------------------------------------------------- 3. tools
if [[ -f $TOPIC_DIR/tools.txt ]]; then
  while read -r tool; do
    [[ -z $tool || $tool == \#* ]] && continue
    echo "› uv tool install $tool"
    if ! uv tool install "$tool"; then
      uv tool upgrade "$tool"
    fi
  done < "$TOPIC_DIR/tools.txt"
fi

echo "› Python toolchain ready ($(uv --version))"
