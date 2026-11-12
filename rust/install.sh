#!/usr/bin/env bash
#
# Install Rust through rustup, then converge the stable toolchain.
#
# Not Homebrew, not mise: rustup is the only thing that writes ~/.rustup and
# ~/.cargo/bin, which keeps the "one owner per runtime" rule in README.md intact
# (node is mise's, python is uv's, bun is Bun's, rust is rustup's). rust/path.zsh
# puts ~/.cargo/bin on PATH for interactive shells; this script does not depend
# on that, it calls the binaries by path.
#
# Idempotent: re-running it is just a `rustup update`.

set -euo pipefail

TOPIC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"

# ------------------------------------------------------------- 1. rustup
if command -v rustup >/dev/null 2>&1; then
  echo "› rustup already installed ($(rustup --version 2>/dev/null | head -1))"
else
  echo "› installing rustup (stable toolchain)"
  # -y                 no interactive prompts
  # --no-modify-path   rustup appends a `. "$HOME/.cargo/env"` line to ~/.zshrc
  #                    and ~/.bashrc. ~/.zshrc is a symlink into this repo, so
  #                    that edit would land in the working tree; $PATH is
  #                    rust/path.zsh's job instead.
  # --profile default  rustc, rust-std, cargo, rust-docs, rustfmt, clippy
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
    sh -s -- -y --no-modify-path --default-toolchain stable --profile default
fi

RUSTUP="$CARGO_HOME/bin/rustup"
CARGO="$CARGO_HOME/bin/cargo"
if [[ ! -x $RUSTUP ]]; then
  echo "rustup missing at $RUSTUP after install -- check CARGO_HOME/RUSTUP_HOME" >&2
  exit 1
fi

# ---------------------------------------------------- 2. toolchain + tools
# Install what is missing, keep what is there (this is why the script is safe to
# re-run from `dot`).
echo "› rustup update stable"
"$RUSTUP" update stable

# Rust configs in nvim/pi want rust-analyzer; it lives in the `complete` profile,
# which is not worth paying for wholesale (rust-src, docs for every platform).
if ! "$RUSTUP" component add rust-analyzer; then
  echo "  could not add the rust-analyzer component (optional, skipped)" >&2
fi

echo "› Rust ready ($("$CARGO" --version))"
