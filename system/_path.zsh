# Keep $PATH free of duplicates: zsh ties `path` to `PATH`, so -U dedupes as
# entries are prepended by the topic files below.
typeset -U path PATH

export PATH="/usr/local/bin:/usr/local/sbin:$ZSH/bin:$HOME/.local/bin:$PATH"
export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"

# opencode
[[ -d $HOME/.opencode/bin ]] && export PATH="$HOME/.opencode/bin:$PATH"

# LM Studio CLI (lms)
[[ -d $HOME/.lmstudio/bin ]] && export PATH="$PATH:$HOME/.lmstudio/bin"
