# Colour comes from `ls` being gls --color (system/aliases.zsh); the BSD pair
# CLICOLOR/LSCOLORS that used to live here only ever affected /bin/ls.

# functions/ is already on fpath via zsh/fpath.zsh, which adds every topic
# directory. Only the non-completion functions are autoloaded here: files
# starting with `_` are compdef definitions and belong to compinit.
autoload -U $ZSH/functions/[^_]*(:t)

HISTFILE=~/.zsh_history
HISTSIZE=200000
SAVEHIST=200000

setopt NO_BG_NICE # don't nice background tasks
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt HIST_VERIFY
setopt EXTENDED_HISTORY # add timestamps to history
setopt PROMPT_SUBST
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF

# History: one block, no duplicates. INC_APPEND_HISTORY implies SHARE_HISTORY's
# effect for our purposes (each command is written as it runs, so concurrent
# panes see each other's history); the old file set SHARE_HISTORY three times.
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS # a command appears once, at its newest position
setopt HIST_IGNORE_SPACE     # leading space = don't record (secrets, one-offs)
setopt HIST_REDUCE_BLANKS

# NOTE: `setopt CORRECT` used to live here. It asked "correct 'gco' to 'gco'?"
# on every typo-shaped alias and added a keystroke to the common path; the
# completion fixes above plus fzf-tab cover the same ground interactively.
# Deliberately not re-added -- if you want it back, put it in ~/.localrc.

# NOTE: `setopt complete_aliases` used to live here. It made zsh treat an
# alias as its own command during completion, so `gco <TAB>` fell back to
# filename completion instead of offering branches. With 12 git aliases in
# git/aliases.zsh that cost far more than it bought; the comment claiming it
# was needed for `git comm-<TAB>` was incorrect. Removed deliberately.

bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[[5D' beginning-of-line
bindkey '^[[5C' end-of-line
bindkey '^[[3~' delete-char
bindkey '^?' backward-delete-char
