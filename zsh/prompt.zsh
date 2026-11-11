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

# The prompt character is the literal glyph at the end of PROMPT (currently a
# lambda); %F{8} paints it bright black and %f resets.
#
# The blank line above the prompt is a separator between the prompt and the
# previous command's output -- so it is only wanted from the *second* prompt on.
# As a static leading $'\n' it also opened every new shell with an empty line
# under "Last login", separating the prompt from nothing. precmd runs before
# every prompt, including the first, so toggling the leading newline there puts
# the blank line exactly where it means something.
_prompt_body=$'$(directory_name) $(git_dirty)$(need_push)\n%F{8}λ%f '
_prompt_first=1
_prompt_precmd () {
  if (( _prompt_first )); then
    _prompt_first=0
    PROMPT="$_prompt_body"
  else
    PROMPT=$'\n'"$_prompt_body"
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_precmd
PROMPT="$_prompt_body"   # something sane before the first precmd
RPROMPT=''
