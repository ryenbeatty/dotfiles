#!/usr/bin/env bash
#
# Install Homebrew, then everything listed in the repo's Brewfile.
#
# The package list lives in ../Brewfile (one declarative file, no loops over
# bash arrays); this script only has to bootstrap brew itself, because
# `brew bundle` needs a working brew to do anything.

set -euo pipefail

TOPIC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$(cd "$TOPIC_DIR/.." && pwd)/Brewfile"

if [[ ! -f $BREWFILE ]]; then
  echo "Brewfile not found at $BREWFILE" >&2
  exit 1
fi

# ------------------------------------------------------------- 1. macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Homebrew installation is only supported on macOS"
  exit 0
fi

# ------------------------------------------------------------- 2. brew
if ! command -v brew >/dev/null 2>&1; then
  echo "› installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Make brew usable for the rest of this script (the shellenv lines only land
  # in ~/.zprofile, which does not affect a running non-login shell).
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "› Homebrew already installed ($(command -v brew))"
fi

# ------------------------------------------------------------- 3. packages
# `install` is idempotent: it skips what is already present, so this is safe to
# re-run from `dot` on any machine. Services are not started here -- yabai and
# skhd are `brew services` decisions, not install decisions.
echo "› brew bundle --file=$BREWFILE"
brew bundle install --file="$BREWFILE"

# ------------------------------------------------- 4. compinit hygiene
# compinit aborts (and, interactively, asks "Ignore insecure directories and
# continue [y] or abort compinit [n]?") if any directory on $fpath is writable
# by group or others. Homebrew's share/ directory is the usual offender -- some
# formulae/installs leave it drwxrwxr-x, and homebrew/path.zsh puts
# share/zsh/site-functions on $fpath.
#
# Only the parents of $fpath get touched here, never the formula trees
# themselves, and `chmod go-w` is a no-op when the mode is already correct.
BREW_PREFIX=$(brew --prefix)
for dir in "$BREW_PREFIX/share" "$BREW_PREFIX/share/zsh" "$BREW_PREFIX/share/zsh/site-functions"; do
  [[ -d $dir ]] || continue
  if [[ -n $(find "$dir" -maxdepth 0 -perm -0020 -o -maxdepth 0 -perm -0002 2>/dev/null) ]]; then
    echo "› tightening $dir (compinit insecure-directory check)"
    chmod go-w "$dir" || echo "  could not chmod $dir -- fix by hand" >&2
  fi
done

echo "› Homebrew + Brewfile up to date"
