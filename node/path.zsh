# mise reads this and switches per directory, following .nvmrc / .node-version
# (enabled by config/mise/config.toml). ~1-3ms, and nothing is resolved until a
# directory asks for a version.
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi
