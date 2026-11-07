# Prompt: <dir> on <branch> ↑<unpushed>, then a chevron line.
# Original by @ehrenmurdick, http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh
#
# Colour uses only native prompt escapes (%F{name} / %f), deliberately NOT
# $fg[...] or $reset_color: those come from `autoload colors`, and dropping that
# call silently strips every colour from the prompt (regression in 4026738).
# %8 is bright black, used for the muted "on" / chevron.

git_branch() {
  local ref
  ref=$(command git symbolic-ref --short HEAD 2>/dev/null) || return
  print -r -- "$ref"
}

git_dirty() {
  local branch
  branch=$(git_branch) || return
  if [[ -z "$(command git status --porcelain 2>/dev/null)" ]]; then
    print -r -- "%F{8}on%f %B%F{green}$branch%f%b"
  else
    print -r -- "%F{8}on%f %B%F{red}$branch%f%b"
  fi
}

# Uses @{upstream}, so it stays correct when the branch is not called `origin/HEAD`.
# (The old version shelled out to `git cherry | wc -l | bc` for this.)
need_push() {
  local count
  count=$(command git rev-list --count '@{upstream}..HEAD' 2>/dev/null) || return
  (( count == 0 )) || print -r -- " %F{yellow}↑$count%f"
}

directory_name() {
  print -r -- "%B%F{cyan}%1/%\/%f%b"
}

PROMPT=$'\n$(directory_name) $(git_dirty)$(need_push)\n%F{8}❯%f '
RPROMPT=''
