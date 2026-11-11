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
brew "ghostty"

# --- core CLI ----------------------------------------------------------------
brew "git"
brew "gh"
brew "jq"
brew "tree"
brew "wget"
brew "tmux"
brew "nvim"

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
