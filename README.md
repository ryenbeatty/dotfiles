# ryen does dotfiles

## topical

Everything's built around topic areas. If you're adding a new area to your
forked dotfiles — say, "Java" — you can simply add a `java` directory and put
files in there. Anything with an extension of `.zsh` will get automatically
included into your shell. Anything with an extension of `.symlink` will get
symlinked without extension into `$HOME` when you run `script/bootstrap`.

## what's inside

A lot of stuff. Seriously, a lot of stuff. Check them out in the file browser
above and see what components may mesh up with you.
[Fork it](https://github.com/holman/dotfiles/fork), remove what you don't
use, and build on what you do use.

## components

There's a few special files in the hierarchy.

- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made
  available everywhere.
- **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your
  environment.
- **topic/path.zsh**: Any file named `path.zsh` is loaded first and is
  expected to setup `$PATH` or similar.
- **topic/completion.zsh**: Any file named `completion.zsh` is loaded
  last and is expected to setup autocomplete.
- **topic/install.sh**: Any file named `install.sh` is executed when you run `script/install`. To avoid being loaded automatically, its extension is `.sh`, not `.zsh`.
- **topic/\*.symlink**: Any file ending in `*.symlink` gets symlinked into
  your `$HOME`. This is so you can keep all of those versioned in your dotfiles
  but still keep those autoloaded files in your home directory. These get
  symlinked in when you run `script/bootstrap`.

## install

Run this:

```sh
git clone https://github.com/ryenbeatty/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

The main file you'll want to change right off the bat is `zsh/zshrc.symlink`,
which sets up a few paths that'll be different on your particular machine.

`dot` is a simple script that installs some dependencies, sets sane macOS
defaults, and so on. Tweak this script, and occasionally run `dot` from
time to time to keep your environment fresh and up-to-date. You can find
this script in `bin/`.

## pi (the coding agent)

`pi/agent/` tracks the *config* half of `~/.pi/agent`, and `script/bootstrap`
links each entry back into place:

| tracked | left alone (machine state) |
|---|---|
| `settings.json`, `keybindings.json`, `models.json`, `mcp.json`, `mcp-adapter.json`, `web-search.json` | `auth.json`, `mcp-auth.json`, `trust.json`, `models-store.json` |
| `extensions/` (each child: plan-mode, deepseek-balance, tool-collapse, hide-footer-status, sandbox, browser) | `sessions/`, `install/`, `mcp-cache.json`, `web-search-cache/`, `*.bak` |
| `npm/package*.json`, `mcp-servers/*/package*.json` | `node_modules/`, `.profile/` |

Linking is per-entry rather than whole-directory, because `~/.pi/agent` is a
mix of config and runtime state: a whole-dir symlink would drag sessions and
caches into git. Same reason `PI_CODING_AGENT_DIR` is not used here.

`models.json` reads the DeepSeek key from the environment:

```json
"apiKey": "${DEEPSEEK_API_KEY}"
```

The value lives in `~/.localrc` (mode 600, outside this repo). pi must be
started from a shell that sourced it, otherwise the provider has no
credential; `pi /login` writes `auth.json` as an alternative.

`pi/agent/install.sh` (run by `script/install`) installs the npm deps for the
browser extension and the tracker MCP server manifests, plus playwright's
chromium the first time.