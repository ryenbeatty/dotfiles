# git's zsh completion (`_git`) ships with zsh itself
# (/usr/share/zsh/5.9/functions/_git) and Homebrew also provides one in
# /opt/homebrew/share/zsh/site-functions, which homebrew/path.zsh puts on
# $fpath before compinit runs. compinit therefore autoloads it on demand.
#
# Nothing to do here. The previous version of this file tried to source
# `$(brew --prefix)/share/zsh/site-functions/_git` but single-quoted the
# command substitution, so the path never expanded and the `test -f` below
# always failed -- it had been dead code for the life of this dotfiles repo.
