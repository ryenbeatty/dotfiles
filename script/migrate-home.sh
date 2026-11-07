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
# Byte-identical to ~/.dotfiles/bin/tmux-sessionizer, which is already on PATH.
if [[ -f $HOME/.local/scripts/tmux-git-sessionizer ]]; then
  run trash "$HOME/.local/scripts/tmux-git-sessionizer"
  run rmdir "$HOME/.local/scripts"   # only succeeds if now empty
fi

hr "~/.codex (101MB, codex is not installed)"
if [[ -d $HOME/.codex ]] && ! command -v codex >/dev/null 2>&1; then
  run du -sh "$HOME/.codex"
  run trash "$HOME/.codex"
fi

# ----------------------------------------------------------------- 4. skills
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
