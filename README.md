# dotfiles

macOS setup, versioned. A topic per concern; each topic is a folder of files
that get sourced into zsh, symlinked into `$HOME`, or run as an installer.

```sh
git clone https://github.com/ryenbeatty/dotfiles.git ~/.dotfiles
~/.dotfiles/script/bootstrap   # symlink files into $HOME
~/.dotfiles/bin/dot            # install every topic's dependencies
```

## layout

```
bin/          scripts on $PATH (dot, e, extract, dns-flush, tmux-sessionizer)
config/       whole-directory symlinks: ~/.config/{nvim,skhd,yabai,uv}
functions/    autoloaded zsh functions (c, gf)
git/          git aliases + multi-line shorthands, completions, gitconfig
system/       $PATH, env vars, base aliases, ~/.hushlogin (silences login banner)
zsh/          zshrc, prompt, history/completion options, vendored plugins
tmux/  nvim/  tmux and neovim config
Brewfile      every Homebrew formula, cask, tap and font (homebrew/install.sh)
script/       bootstrap, install, migrate-home
skills/       agent skills, shared by every harness
```

Runtime topics — `node/`, `python/`, `bun/`, `homebrew/` — own their own
`install.sh` and `path.zsh`:

| runtime | owner | switching |
|---|---|---|
| node | mise (`config/mise/config.toml`) | per-directory via `.nvmrc` / `.node-version` |
| python + CLIs | uv (`python/pythons.txt`, `python/tools.txt`) | `uv python install` / `uv tool install` |
| bun | Bun's own installer (`~/.bun/bin`) | n/a |
| everything else | Homebrew (`Brewfile`) | n/a |

No pyenv, no fnm, no nvm, no pnpm, no yarn: one owner per runtime, so a binary
can never come from two places.

## how files load

- `topic/*.zsh` — sourced into every interactive shell.
- `topic/path.zsh` — sourced **first**; sets up `$PATH` and `fpath`.
- `topic/completion.zsh` — sourced **last**, after `compinit`.
- `topic/*.symlink` — symlinked into `$HOME` without the extension.
- `topic/install.sh` — run by `bin/dot` → `script/install`; never sourced.

`zsh/zshrc.symlink` is the entry point: it globs `$ZSH/**/*.zsh`, skips the
vendored plugins under `zsh/plugins/`, and sources the rest in that order.
`zsh/fpath.zsh` puts every topic directory on `fpath` (deduped), which is how a
topic can ship a `functions/` entry or a `#compdef` file and have it found with
no extra wiring.

`zsh/plugins/` is vendored, not submoduled: two plugins, ~40 files, with the
upstream test fixtures and CI configs stripped. zsh-autosuggestions is not here
on purpose -- see the note in `zsh/zshrc.symlink`.

## day to day

```sh
dot                 # install/update everything, idempotent
dot -e              # open this repo in $EDITOR
brew bundle check --file=~/.dotfiles/Brewfile   # what's missing, install nothing
```

`script/migrate-home.sh` is the one-off convergence script for the parts of
`$HOME` a repo can't own (stale symlinks, retired toolchains, dead state). It
defaults to a dry run:

```sh
bash ~/.dotfiles/script/migrate-home.sh           # print intended actions
bash ~/.dotfiles/script/migrate-home.sh --apply   # do them
```

It is re-runnable and guards each removal, so a second pass is a no-op.

`setup-scripts/` is a dated snapshot of an old laptop build, kept for reference
only — the live path is `script/bootstrap` + `bin/dot`.
