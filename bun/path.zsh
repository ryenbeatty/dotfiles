# bun
# Installed by Bun's own installer, which also owns ~/.bun/bin -- the global
# CLIs installed with `bun install -g` (qmd, agentation) live there. The Homebrew
# formula was a second copy of the runtime, so ~/.bun/bin is the only bun on PATH
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"