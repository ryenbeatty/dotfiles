# Prompt: branch name coloured by dirty state, plus an unpushed-commit count.
# Original by @ehrenmurdick, http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh

# Branch name, or empty when not on a branch (detached HEAD).
git_branch() {
  local ref
  ref=$(command git symbolic-ref --short HEAD 2>/dev/null) || return
  print -r -- "$ref"
}

git_dirty() {
  local branch
  branch=$(git_branch) || return
  if [[ -z "$(command git status --porcelain 2>/dev/null)" ]]; then
    print -r -- "on %{$fg_bold[green]%}$branch%{$reset_color%}"
  else
    print -r -- "on %{$fg_bold[red]%}$branch%{$reset_color%}"
  fi
}

# Uses @{upstream}, so it stays correct when the branch is not called `origin/HEAD`.
# (The old version shelled out to `git cherry | wc -l | bc` for this.)
need_push() {
  local count
  count=$(command git rev-list --count '@{upstream}..HEAD' 2>/dev/null) || return
  (( count == 0 )) || print -r -- " with %{$fg_bold[magenta]%}$count unpushed%{$reset_color%}"
}

directory_name() {
  print -r -- "%{$fg_bold[cyan]%}%1/%\/%{$reset_color%}"
}

PROMPT=$'\n$(directory_name) $(git_dirty)$(need_push)\n› '
RPROMPT=''
