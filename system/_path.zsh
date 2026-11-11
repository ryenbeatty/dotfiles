# Keep $PATH free of duplicates: zsh ties `path` to `PATH`, so -U dedupes as
# entries are prepended by the topic files below.
typeset -U path PATH

# Only what neither Homebrew nor a runtime owns: the repo's bin/, and
# ~/.local/bin (uv tool shims, misc `python -m pip install --user`-style
# entry points). Homebrew's own prefix comes from homebrew/path.zsh.
#
# The old /usr/local/{bin,sbin} entries and the /usr/local/{mysql,git}/man
# MANPATH were Intel-era leftovers: nothing installs there on Apple Silicon, and
# the real prefixes already arrive via `brew shellenv` in ~/.zprofile.
export PATH="$ZSH/bin:$HOME/.local/bin:$PATH"
