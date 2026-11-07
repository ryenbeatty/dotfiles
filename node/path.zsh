# fnm reads .nvmrc / .node-version and switches per directory, so the three
# .nvmrc files in ~/Code start working again. The hook is ~1-2ms and appends
# fnm's multishell dir to PATH; nothing is resolved until a directory asks.
if (( $+commands[fnm] )); then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi
