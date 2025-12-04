# Work Laptop Setup - December 2025

This directory contains scripts to automate the setup of a new macOS work laptop based on ryenbeatty's development environment as of December 2025.

## 🚀 Quick Setup

For a complete new machine setup, run these scripts in order:

```bash
# 1. Install Homebrew packages (CLI tools and GUI apps)
./homebrew-packages.sh

# 2. Set up development environments
./development-tools.sh

# 3. Configure macOS system preferences
./macos-settings.sh
```

## 📋 Individual Scripts

### 🍺 homebrew-packages.sh

Installs software packages discovered on the current system via Homebrew.

**Usage:**
```bash
# Install everything (default)
./homebrew-packages.sh

# Install only CLI tools
./homebrew-packages.sh --cli-only

# Install only GUI applications
./homebrew-packages.sh --gui-only
```

**What it installs:**

**CLI Tools & Libraries (Audited - 25+ essential tools):**
- **Development:** git, gh, node, neovim, emacs-mac
- **System utilities:** fzf, ripgrep, tmux, mas, neofetch, watch
- **Package managers:** pnpm, uv, pyenv
- **Window management:** skhd, yabai
- **Media processing:** youtube-dl, imagemagick, ffmpeg
- **Security:** gnupg (includes pinentry)
- **Network:** wget (curl comes with macOS)
- **Note:** Removed 40+ packages that are macOS defaults or dependencies

**GUI Applications:**
- **Terminals:** alacritty, ghostty
- **Browsers:** arc, brave-browser, firefox, google-chrome, zen-browser
- **Development:** cursor, github-desktop, docker, postman, figma, xcode
- **Communication:** discord, slack, telegram, zoom, loom
- **Productivity:** notion, obsidian, todoist, raycast, cleanshot-x
- **Media:** vlc, gimp, obs, screen-studio
- **Utilities:** hiddenbar, carbon-copy-cloner, backblaze, karabiner-elements
- **VPN & Security:** nordvpn, mullvad-vpn, protonvpn
- **Audio production:** reaper, loopback, audio-hijack, soundsource

**Mac App Store Apps:**
- Keynote, Numbers, Pages, iMovie, GarageBand

**Global npm packages:**
- @anthropic-ai/claude-code, neonctl, flashbacker

### 🛠️ development-tools.sh

Sets up development environments for multiple programming languages.

**What it installs:**
- **Node.js** via NVM (latest LTS)
- **Python** via pyenv (3.12.7 + essential packages)
- **Bun** (fast JavaScript runtime)
- **Rust** via rustup
- **Go** via Homebrew
- **Java** (Temurin JDK)
- **Databases:** PostgreSQL, Redis, SQLite
- **Global packages:** TypeScript, ESLint, Prettier, etc.

### 🍎 macos-settings.sh

Configures macOS system preferences for development and productivity.

**What it configures:**
- **General UI/UX:** Disable boot sound, configure scrollbars, disable auto-termination
- **Dock:** Auto-hide, scale effect, show indicators, faster animations
- **Finder:** Show hidden files, extensions, path bar, disable warnings
- **Keyboard:** Fast key repeat, disable auto-correct/smart features
- **Trackpad:** Tap to click, right-click corner
- **Safari:** Enable developer tools, privacy settings
- **Terminal:** UTF-8, secure keyboard entry
- **Screen capture:** PNG format, save to desktop, no shadows
- **Activity Monitor:** Show all processes, sort by CPU

## 📦 Manual Installation Required

Some applications need to be installed manually (not available via Homebrew):

### 🎵 Audio Production
- Ableton Live 12 Suite
- Native Instruments (via Native Access)
- iZotope products (RX 11, Product Portal)
- Plugin Alliance plugins
- Waves plugins and Central
- Spitfire Audio
- Neural DSP plugins
- And many other audio production tools...

### 🎬 Video Production
- DaVinci Resolve
- Blackmagic RAW tools

### 💬 Communication & Productivity
- ChatGPT, Claude, Perplexity AI
- Warp terminal
- Various utility apps

**Check the full list by running:**
```bash
./homebrew-packages.sh --all
```

## 🔧 Usage Tips

1. **Make scripts executable:**
   ```bash
   chmod +x *.sh
   ```

2. **Run scripts individually** if you only need specific components

3. **Check what's already installed** - scripts skip already-installed packages

4. **Review before running** - especially the macOS settings script as it modifies system preferences

5. **Some installs require interaction:**
   - Mac App Store apps require being signed in
   - Some casks may need additional permissions

## 🆕 Keeping Updated

To keep this up to date:

1. **Update package lists** by analyzing current installations:
   ```bash
   brew list --formula > current-formulas.txt
   brew list --cask > current-casks.txt
   ls /Applications > current-apps.txt
   ```

2. **Add new discoveries** to the respective scripts

3. **Test on a fresh system** or VM when possible

## 📝 Notes

- Scripts are idempotent - safe to run multiple times
- Some packages may fail to install due to system differences
- Manual apps list is comprehensive but may need updates over time
- Consider your specific needs before running everything