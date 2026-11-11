# `ls` is gls (coreutils, from the Brewfile) -- BSD /bin/ls cannot do --color or
# the -A/-F combination below. The CLICOLOR/LSCOLORS pair that used to sit in
# zsh/config.zsh only ever affected /bin/ls, so it is gone.
if command -v gls >/dev/null 2>&1; then
  alias ls='gls -F --color=auto'
  alias l='gls -lAh --color=auto'
  alias ll='gls -l --color=auto'
  alias la='gls -A --color=auto'
else
  alias ls='ls -F'
  alias l='ls -lAh'
  alias ll='ls -l'
  alias la='ls -A'
fi
