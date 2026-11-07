#!/usr/bin/env bash
#
# Converge the Node toolchain: fnm, the versions listed in versions.txt, and
# Corepack (which is what makes the "packageManager" fields in your projects
# meaningful again -- Node 26 no longer ships it).
#
# Run by script/install (i.e. by `dot`), or directly.
#
set -euo pipefail

TOPIC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------- 1. fnm
if ! command -v fnm >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    echo "› installing fnm (brew)"
    brew install --quiet fnm
  else
    echo "fnm is missing and Homebrew is not available; install fnm manually" >&2
    exit 1
  fi
fi

# ----------------------------------------------------------- 2. versions
# --corepack-enabled installs Corepack alongside each version, so `pnpm -v` and
# `npm -v` inside a project match its packageManager field.
default_version=""
if [[ -f $TOPIC_DIR/versions.txt ]]; then
  while read -r version; do
    [[ -z $version || $version == \#* ]] && continue
    [[ -z $default_version ]] && default_version=$version
    echo "› fnm install $version"
    fnm install --corepack-enabled "$version"
  done < "$TOPIC_DIR/versions.txt"
fi

if [[ -n $default_version ]]; then
  echo "› fnm default $default_version"
  fnm default "$default_version"
  echo "› corepack enable"
  fnm exec --using="$default_version" corepack enable
fi

echo "› Node toolchain ready ($(fnm --version), default ${default_version:-none})"
