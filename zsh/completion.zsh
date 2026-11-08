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
# No `menu`/`select`/`select-prompt` here any more. The completion menu is now
# fzf-tab (zsh/plugins/fzf-tab, sourced from zshrc.symlink): it replaces zsh's
# arrow-key menu with an fzf picker, so those styles only described a UI that
# never appears. fzf-tab forces `list-grouped false` itself and renders group
# headers from the `descriptions` format below.

# --- annotated, grouped, coloured listings ----------------------------------
zstyle ':completion:*' group-name ''
# Plain text on purpose: fzf-tab ignores escape sequences in this format and
# uses it as its group header. The colours were for zsh's own menu, which is
# gone now.
zstyle ':completion:*:descriptions' format '[%d]'
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
# `..` as a candidate is one of the ways a completion list ends up offering a
# directory you are not in. The parent is one `cd -` away; it does not need to be
# TAB-completed.
zstyle ':completion:*' special-dirs false
zstyle ':completion:*' squeeze-slashes true # `cd foo//bar` -> `cd foo/bar`
# tag-order *restricts* completion to the tags listed. The old value named
# path-directories (i.e. cdpath) and directory-stack, which kept both in play --
# the comment above it claimed the opposite. A lone `-` value means "only the
# tags named, never fall back to the unlisted ones", so `cd <TAB>` can now only
# offer directories inside $PWD. (`directory-stack` is dead weight in practice:
# `_cd` only asks for it when the word starts with a `-`/`+`.)
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack -

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

# ============================================================================
# fzf-tab
# ============================================================================
# Inert unless zsh/plugins/fzf-tab is present (see the source in zshrc.symlink).
#
# fzf-tab does not read FZF_DEFAULT_OPTS (some flags break it), and this repo
# sets FZF_DEFAULT_COMMAND only, so the picker stays default-clean.
zstyle ':fzf-tab:*' fzf-flags --height=60% --bind=tab:accept
# Show what is inside the directory you are about to cd into.
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'command ls -1 $realpath'
