#!/usr/bin/env bash
#
# migrate-home.sh -- one-time cleanup of the parts of $HOME that the dotfiles
# repo cannot own by itself (symlinks inside ~/.config, dead tool state).
#
# Everything here is idempotent-ish and uses `trash` instead of `rm` where the
# content is not trivially reproducible. Read it before running it.
#
#   bash ~/.dotfiles/script/migrate-home.sh          # dry run, prints actions
#   bash ~/.dotfiles/script/migrate-home.sh --apply
#
set -uo pipefail

DOTFILES="$HOME/.dotfiles"
APPLY=false
[[ ${1:-} == "--apply" ]] && APPLY=true

run () {
  if $APPLY; then
    "$@"
  else
    printf '  would: %s\n' "$*"
  fi
}

hr () { printf '\n== %s\n' "$1"; }

# ------------------------------------------------------------------ 0. backup
# Snapshot both halves before touching anything: the git history (portable
# bundle, independent of the working tree) and every $HOME file this script is
# about to replace or trash.
hr "backup"
BK="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
run mkdir -p "$BK"
run git -C "$DOTFILES" bundle create "$BK/dotfiles-all-refs.bundle" --all
run tar -czf "$BK/dotfiles-worktree.tgz" -C "$DOTFILES" \
  --exclude=./.git --exclude=./.backup --exclude=./.pi/quiet-tools .
run tar -czf "$BK/home-state.tgz" -C "$HOME" \
  .alacritty.toml .skhdrc .localrc \
  .config/alacritty .config/skhd .config/yabai \
  .claude/skills/bunny-cli .claude/skills/rex .qwen/skills/interface-craft \
  .pi/agent/skills/supacode-cli .pi/agent/skills/supacode-deeplinks \
  .agents/.skill-lock.json .local/scripts/tmux-git-sessionizer
printf '  backup target: %s\n' "$BK"
if $APPLY && [[ -d $BK ]]; then
  du -sh "$BK" | sed 's/^/  /'
fi

# ---------------------------------------------------------------- 1. secrets
hr "private env file"
if [[ -f $HOME/.localrc ]]; then
  run chmod 600 "$HOME/.localrc"
  printf '  ~/.localrc exists with %s mode\n' "$(stat -f '%OLp' "$HOME/.localrc")"
else
  echo "  MISSING: ~/.localrc (the API keys moved here; recreate it)"
fi

# --------------------------------------------------------- 2. config symlinks
# Upstream renamed config/<topic>/<file>.symlink to plain names, so the old
# per-file links in ~/.config now dangle. Replace them with whole-dir links,
# which is what script/bootstrap does from now on.
hr "~/.config topic links"
for topic in alacritty skhd yabai nvim; do
  src="$DOTFILES/config/$topic"
  dst="$HOME/.config/$topic"
  [[ -d $src ]] || continue

  if [[ -L $dst ]]; then
    printf '  %s: already a symlink -> %s\n' "$dst" "$(readlink "$dst")"
    continue
  fi
  if [[ -d $dst ]]; then
    echo "  $dst is a real directory:"
    find "$dst" -maxdepth 2 -mindepth 1 | sed 's/^/    /'
    run trash "$dst"
  fi
  run ln -s "$src" "$dst"
done

hr "stale files superseded by the repo"
# The live alacritty config and the dangling ~/.skhdrc both point at names that
# no longer exist; ~/.config/alacritty/alacritty.toml now wins.
for f in "$HOME/.alacritty.toml" "$HOME/.skhdrc"; do
  [[ -e $f || -L $f ]] || continue
  printf '  %s -> %s\n' "$f" "$(readlink "$f" 2>/dev/null || echo 'regular file')"
  run trash "$f"
done

# ------------------------------------------------------------- 3. dead clones
hr "unused ~/.oh-my-zsh clone (24MB)"
# zsh/plugins/{zsh-autosuggestions,zsh-syntax-highlighting} are vendored in the
# repo and $ZSH points at ~/.dotfiles, so nothing reads this anymore.
if [[ -d $HOME/.oh-my-zsh ]]; then
  run du -sh "$HOME/.oh-my-zsh"
  run trash "$HOME/.oh-my-zsh"
fi

hr "~/.local/scripts/tmux-git-sessionizer"
# Byte-identical to ~/.dotfiles/bin/tmux-sessionizer. bin/ is on PATH and also
# exposes the old name (bin/tmux-git-sessionizer -> tmux-sessionizer), so
# removing this copy loses nothing.
if [[ -f $HOME/.local/scripts/tmux-git-sessionizer ]]; then
  run trash "$HOME/.local/scripts/tmux-git-sessionizer"
  run rmdir "$HOME/.local/scripts"   # only succeeds if now empty
fi

hr "old neovim plugin state (the retired NvChad stack)"
# config/nvim is now a hand-rolled lazy.nvim setup. These directories belong to
# the previous NvChad install (NvChad + base46/ui/cmps) and to plugins that were
# removed from the spec. Nothing in the new config references them.
NVIM_DATA="$HOME/.local/share/nvim"
if [[ -d $NVIM_DATA ]]; then
  for d in NvChad base46 ui volt menu minty nvim-cmp cmp_luasnip cmp-buffer \
           cmp-nvim-lsp cmp-nvim-lua cmp-path null-ls.nvim prettier.nvim \
           vim-be-good mini.main.cloning; do
    [[ -e $NVIM_DATA/lazy/$d ]] || continue
    run trash "$NVIM_DATA/lazy/$d"
  done
  # generated highlight cache from NvChad's base46
  [[ -d $NVIM_DATA/base46 ]] && run trash "$NVIM_DATA/base46"
fi

hr "~/.codex (101MB, codex is not installed)"
if [[ -d $HOME/.codex ]] && ! command -v codex >/dev/null 2>&1; then
  run du -sh "$HOME/.codex"
  run trash "$HOME/.codex"
fi

hr "python toolchain: pyenv + rye + conda -> uv"
# Five Python sources were installed; the shell resolved to the worst one. uv is
# the keeper (python/install.sh, config/uv/uv.toml).
if [[ -d $HOME/.pyenv ]]; then
  run du -sh "$HOME/.pyenv"
  # one global 3.12.4 with 276 packages installed straight into it -- keep a
  # record before it goes, in case some CLI turns out to be needed
  if command -v pyenv >/dev/null 2>&1; then
    run sh -c "pyenv exec pip freeze > '$BK/pyenv-3.12.4-freeze.txt'"
  fi
  run trash "$HOME/.pyenv"
fi

# rye: `use-uv = true` + `global-python = true` made it a wrapper over uv whose
# shims were only ever exported from ~/.profile (bash login shells).
if [[ -d $HOME/.rye ]]; then
  run trash "$HOME/.rye"
  if grep -q 'rye/env' "$HOME/.profile" 2>/dev/null; then
    run cp "$HOME/.profile" "$HOME/.profile.bak"
    run sed -i '' '/\. "\$HOME\/\.rye\/env"/d' "$HOME/.profile"
  fi
fi

# conda: miniconda cask with a leftover pytorch/ComfyUI env, initialised only in
# ~/.bash_profile. Drop the whole thing if comfyenv is no longer wanted.
if [[ -d $HOME/.conda ]]; then
  run du -sh "$HOME/.conda"
  run trash "$HOME/.conda"
  if grep -q 'conda initialize' "$HOME/.bash_profile" 2>/dev/null; then
    run cp "$HOME/.bash_profile" "$HOME/.bash_profile.bak"
    run sed -i '' '/# >>> conda initialize >>>/,/# <<< conda initialize <<</d' "$HOME/.bash_profile"
  fi
fi

# pyenv-virtualenv was never a keg -- it lived in ~/.pyenv/plugins and went with
# ~/.pyenv above, so uninstalling it here only errors.
run brew uninstall pyenv
run brew uninstall --cask miniconda

# Homebrew's python@3.12 / python@3.15 are deliberately KEPT: brew reports them as
# dependencies of youtube-dl and yt-dlp, so removing them would break those. They
# are also irrelevant now -- config/uv/uv.toml sets python-preference = "managed",
# so uv never falls back to them.

# uv itself: switch from the standalone installer to the formula. Its receipt
# blocks config/uv being a symlink into the repo, and its ~/.local/bin/uv would
# shadow brew's (that dir comes first on PATH) -- so install, then drop it.
if command -v brew >/dev/null 2>&1; then
  run brew install --quiet uv
fi
[[ -f $HOME/.local/bin/uv ]] && run trash "$HOME/.local/bin/uv"
[[ -f $HOME/.local/bin/uvx ]] && run trash "$HOME/.local/bin/uvx"
[[ -d $HOME/.config/uv ]] && run trash "$HOME/.config/uv"

# uv hygiene: stale 3.11 alias, and the 4.4G cache (prune is conservative --
# `uv cache clean` reclaims all of it)
if command -v uv >/dev/null 2>&1; then
  run uv python uninstall 3.11
  run uv cache prune
fi

# ----------------------------------------------------------------- 4. node
hr "node: fnm + corepack"
# fnm takes over version switching (node/install.sh). Two leftovers to tidy:
# a mixed .nvmrc spelling, and the record of what is welded to the Homebrew node.
if [[ -f $HOME/Code/ReactTube/.nvmrc ]] && grep -qx 'v24' "$HOME/Code/ReactTube/.nvmrc" 2>/dev/null; then
  run cp "$HOME/Code/ReactTube/.nvmrc" "$BK/ReactTube.nvmrc.bak"
  run sh -c "printf '24\n' > '$HOME/Code/ReactTube/.nvmrc'"
fi

# Global npm packages live inside the Homebrew node install, so record them
# before anything touches it (they need reinstalling under fnm's versions).
if command -v npm >/dev/null 2>&1; then
  run sh -c "npm ls -g --depth=0 > '$BK/npm-globals.txt' 2>&1 || true"
fi

# bun is installed twice. Bun's own installer owns ~/.bun and the global CLIs in
# ~/.bun/bin, so drop the Homebrew formula and let bun/path.zsh be the only one.
[[ -d /opt/homebrew/Cellar/bun ]] && run brew uninstall bun

# ----------------------------------------------------------------- 5. skills
hr "skill harness links"
# One tree (~/.dotfiles/skills, symlinked as ~/.agents/skills) for every
# harness; these three were real copies, so they could drift.
for pair in "$HOME/.claude/skills/bunny-cli" "$HOME/.claude/skills/rex" "$HOME/.qwen/skills/interface-craft"; do
  [[ -d $pair && ! -L $pair ]] || continue
  name=$(basename "$pair")
  run trash "$pair"
  run ln -s "$HOME/.agents/skills/$name" "$pair"
done
# The pi-only skills now live in the repo (committed); swap them for symlinks.
for name in supacode-cli supacode-deeplinks; do
  src="$HOME/.pi/agent/skills/$name"
  [[ -d $src && ! -L $src ]] || continue
  run trash "$src"
  run ln -s "$HOME/.agents/skills/$name" "$src"
done

hr "skill lock"
# ~/.agents/.skill-lock.json is the installer's provenance file; the versioned,
# pruned copy lives in the repo and bootstrap links it.
if [[ -f $DOTFILES/skills/.skill-lock.json ]]; then
  if [[ -f $HOME/.agents/.skill-lock.json && ! -L $HOME/.agents/.skill-lock.json ]]; then
    run cp "$HOME/.agents/.skill-lock.json" "$HOME/.agents/.skill-lock.json.bak"
  fi
  run ln -sfn "$DOTFILES/skills/.skill-lock.json" "$HOME/.agents/.skill-lock.json"
fi

hr "done"
if $APPLY; then
  echo "Applied. Open a new shell, then: brew services restart yabai; brew services restart skhd"
else
  echo "Dry run only. Re-run with --apply to make these changes."
fi
