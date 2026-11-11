# The rest of my fun git aliases
alias gl='git pull --prune'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gp='git push origin HEAD'

# Remove `+` and `-` from start of diff lines; just rely upon color.
alias gd='git diff --color | sed "s/^\([^-+ ]*\)[-+ ]/\\1/" | less -r'

alias gc='git commit'
alias gcl='git clone'
alias gca='git commit -a'
alias gco='git checkout'
alias gcb='git branch --show-current | pbcopy'
alias gb='git branch'
alias gs='git status -sb' # upgrade your git if -sb breaks for you. it's fun.
alias gac='git add -A && git commit -m'

# --- multi-line shorthands ------------------------------------------------
# These used to be standalone `bin/git-*` scripts: a file, a shebang and a PATH
# lookup each, for one git invocation. Same names, now plain shell functions --
# they work in any shell that sources this file, and `type git-undo` shows the
# body instead of hiding it in a subprocess.

git-amend () {
  git commit --amend -C HEAD "$@"
}

git-undo () {
  git reset --soft HEAD^
}

git-nuke () {
  if (( $# != 1 )); then
    echo "usage: git-nuke <branch>" >&2
    return 1
  fi
  git branch -D "$1" && git push origin ":$1"
}

git-delete-local-merged () {
  local merged
  merged=$(git branch --merged | grep -v '^\*' | grep -v 'master' | tr -d ' ')
  if [[ -z $merged ]]; then
    echo "nothing merged into HEAD" >&2
    return 0
  fi
  git branch -d ${(f)merged}
}

git-unpushed () {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD) || return
  git diff "origin/$branch..HEAD" "$@"
}

git-unpushed-stat () {
  local branch count s
  branch=$(git rev-parse --abbrev-ref HEAD) || return
  count=$(git rev-list --count "HEAD" "origin/$branch...HEAD")
  (( count == 1 )) || s='s'
  git diff --stat "origin/$branch..HEAD"
  echo " $count commit$s total"
}

# Watching a repo is a loop, not an alias: this used to be one line of
# alias-quoting-into-watch-into-sh. Single quotes survive the double quotes here,
# so watch's shell sees a plain --pretty=format:'...'.
gittail () {
  watch -n 1 -c "git log --graph --pretty=format:'%h %d %s %cr' --abbrev-commit -15"
}
