export PATH="/opt/homebrew/bin:$PATH"

# Homebrew's formula completions (_brew, _gh, _bun, _uv, _rg, _wt, _deno, ...).
# `brew shellenv` injects this directory into fpath, but it is called from
# ~/.zprofile, which only runs for LOGIN shells. A nested `zsh`, a non-login
# tmux pane or an editor terminal would silently lose every formula completion.
# Adding it here means every interactive shell gets them, login or not.
HOMEBREW_PREFIX=${HOMEBREW_PREFIX:-/opt/homebrew}
if [[ -d $HOMEBREW_PREFIX/share/zsh/site-functions ]]; then
  typeset -U fpath
  fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)
fi
