#!/usr/bin/env bash
#
# Converge the Node toolchain: mise, then every version listed in versions.txt.
#
# The version *selection* lives in config/mise/config.toml (linked to
# ~/.config/mise/config.toml by script/bootstrap), so nothing here writes
# global state -- this script only makes sure the runtimes exist.
#
# Run by script/install (i.e. by `dot`), or directly.
#
set -euo pipefail

TOPIC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --------------------------------------------------------------- 1. mise
if ! command -v mise >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    echo "› installing mise (brew)"
    brew install --quiet mise
  else
    echo "mise is missing and Homebrew is not available; install mise manually" >&2
    exit 1
  fi
fi

# ------------------------------------------------------------- 2. node
if [[ -f $TOPIC_DIR/versions.txt ]]; then
  while read -r version; do
    [[ -z $version || $version == \#* ]] && continue
    echo "› mise install node@$version"
    mise install "node@$version"
  done < "$TOPIC_DIR/versions.txt"
fi

# Anything requested by config/mise/config.toml that is not in versions.txt
# (e.g. after editing the default) gets installed too.
echo "› mise install (from config)"
mise install

echo "› Node toolchain ready: $(mise ls node 2>/dev/null | head -3 | tr '\n' ' ')"
