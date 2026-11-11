# Brewfile -- everything this machine gets from Homebrew.
#
#   brew bundle install --file=~/.dotfiles/Brewfile
#
# Applied by homebrew/install.sh (i.e. by `dot`). `brew bundle check` tells you
# what is missing without installing anything; `brew bundle dump` regenerates a
# starting point if you want to reconcile by hand.
#
# Version-managed runtimes are deliberately NOT here: node comes from mise
# (node/install.sh, config/mise/config.toml), python and its CLIs from uv
# (python/install.sh), and bun from Bun's own installer (bun/path.zsh).

tap "koekeishiya/formulae"

# --- shell & terminal ---------------------------------------------------------
brew "zsh-completions" # homebrew/path.zsh adds its fpath if present
brew "fzf"             # Ctrl-R history, fzf-tab, tmux-sessionizer
brew "ripgrep"         # grep replacement; also nvim's picker backend
brew "grc"             # colourised output for common commands
brew "coreutils"       # gls etc. -- system/aliases.zsh keys off gls
brew "watch"           # gittail alias

# --- core CLI ----------------------------------------------------------------
brew "git"
brew "gh"
brew "jq"
brew "tree"
brew "wget"
brew "tmux"
brew "neovim"           # formula is neovim, not nvim
brew "deno"             # nvim/pi tooling (better-sqlite3 builds, TS scripts)
brew "esbuild"          # borrowed by tsup/vite workflows
brew "ffmpeg"           # media conversion; also imagemagick's runtime

# --- toolchains --------------------------------------------------------------
brew "mise"            # node version switching (node/install.sh)
brew "uv"              # python + uv tools (python/install.sh)
brew "node"            # kept for neonctl / prettierd; project versions are mise's

# --- window management -------------------------------------------------------
brew "koekeishiya/formulae/yabai"
brew "koekeishiya/formulae/skhd"

# --- browsers ----------------------------------------------------------------
cask "zen-browser"
cask "firefox"

# --- terminals ---------------------------------------------------------------
cask "ghostty"         # current terminal (alacritty: see note at EOF)

# --- apps --------------------------------------------------------------------
cask "alacritty"
cask "cleanshot"
cask "superwhisper"
cask "shifty"
cask "mullvad"
cask "syncthing"
cask "figma"
cask "paper"
cask "xcode"
cask "zoom"
cask "handy"
cask "vorssaint"
cask "raycast"
cask "obsidian"
cask "keepassxc"
cask "todoist"
cask "the-unarchiver"
cask "vlc"
cask "steermouse"
cask "karabiner-elements"
cask "cold-turkey-blocker"

# --- fonts -------------------------------------------------------------------
cask "font-blex-mono-nerd-font"
cask "font-geist-mono-nerd-font"

# --- deliberately not managed ------------------------------------------------
# Installed on this machine but not declared above, so 'brew bundle' will not
# touch them: cocoapods, emacs-mac (neither used by the dotfiles). Uninstall
# them if you do not want them.
#
# cask "alacritty" is declared above but Alacritty is not in Homebrew's Caskroom
# on this machine -- the copy in /Applications was installed by hand. It is kept
# because config/alacritty/ is still versioned; delete both if Ghostty has fully
# replaced it.
