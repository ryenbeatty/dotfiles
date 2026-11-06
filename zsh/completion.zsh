# enter directory by typing folder name
setopt autocd

# ============================================================================
# completion configuration  (sourced AFTER compinit, so these all take effect)
# ============================================================================

# --- matching ---------------------------------------------------------------
# 1st pass: case insensitive, 2nd: partial word ("git ch" -> "git checkout"),
# 3rd: substring anywhere ("ods" -> "node_modules").
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

# try exact matches, then spell-fix, then approximate ("did you mean")
zstyle ':completion:*' completer _expand _complete _approximate
zstyle ':completion:*' max-errors 2 numeric

# --- the menu ---------------------------------------------------------------
# TAB twice opens an arrow-key menu instead of just re-listing.
zstyle ':completion:*' menu select
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

# --- annotated, grouped, coloured listings ----------------------------------
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages'     format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings'     format '%F{red}-- no matches for: %d --%f'
zstyle ':completion:*:corrections'  format '%F{green}-- %d (errors: %e) --%f'

# file-type colours in the completion list. LS_COLORS is usually unset on macOS
# (it sets LSCOLORS for ls), so fall back to a sane palette.
if [[ -n $LS_COLORS ]]; then
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
else
  zstyle ':completion:*' list-colors \
    'di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=1;33:cd=1;33:su=37;41:sg=30;43'
fi
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# --- paths ------------------------------------------------------------------
zstyle ':completion:*' special-dirs true    # complete . and .. as directories
zstyle ':completion:*' squeeze-slashes true # `cd foo//bar` -> `cd foo/bar`
# don't offer PATH executables / named dirs when completing after cd
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# --- cache & freshness ------------------------------------------------------
# cache expensive completions (dpkg/apt style listings, git refs, ...)
zstyle ':completion:*' use-cache yes
_zcompcache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
[[ -d $_zcompcache ]] || mkdir -p $_zcompcache
zstyle ':completion:*' cache-path $_zcompcache
unset _zcompcache

# pick up newly installed binaries (brew install ...) without a new shell
zstyle ':completion:*' rehash true

# --- misc polish ------------------------------------------------------------
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true
# readable process list for `kill <TAB>`
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# ============================================================================
# completion key bindings
# ============================================================================
# shift-TAB cycles backwards through the completion candidates.
#
# The `menuselect` keymap needs no entry here: zsh creates it lazily, only once
# a menu is actually entered (so it cannot be bound from a startup file or
# even from a first-prompt hook -- it always fails with "no such keymap").
# It ships its own bindings; plain shift-TAB above already reaches it because
# the main keymap binding is what starts the menu.
if [[ -o zle ]]; then
  bindkey '^[[Z' reverse-menu-complete
fi
