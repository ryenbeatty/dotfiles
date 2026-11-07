# yarn global binaries
if (( $+commands[yarn] )); then
  export PATH="$PATH:$(yarn global bin 2>/dev/null)"
fi

# node comes from Homebrew; nvm is not installed and the nvm/ topic was removed.
