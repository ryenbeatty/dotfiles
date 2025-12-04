#!/usr/bin/env bash
#
# macOS System Preferences and Settings
# Configures macOS system settings for development and productivity

set -euo pipefail

info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

# Close System Preferences to prevent conflicts
close_system_preferences() {
    osascript -e 'tell application "System Preferences" to quit'
}

# General UI/UX settings
set_general_settings() {
    info "Configuring general UI/UX settings..."

    # Set computer name (update these with your preferences)
    # sudo scutil --set ComputerName "YourMacBookPro"
    # sudo scutil --set HostName "YourMacBookPro"
    # sudo scutil --set LocalHostName "YourMacBookPro"

    # Disable the sound effects on boot
    sudo nvram SystemAudioVolume=" "

    # Menu bar: hide battery percentage
    defaults write com.apple.menuextra.battery ShowPercent -string "NO"

    # Always show scrollbars
    defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

    # Disable automatic termination of inactive apps
    defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

    # Disable Resume system-wide
    defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

    # Set sidebar icon size to medium
    defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

    success "General settings configured"
}

# Dock settings
configure_dock() {
    info "Configuring Dock settings..."

    # Set the icon size of Dock items to 48 pixels
    defaults write com.apple.dock tilesize -int 48

    # Change minimize/maximize window effect to scale
    defaults write com.apple.dock mineffect -string "scale"

    # Minimize windows into their application's icon
    defaults write com.apple.dock minimize-to-application -bool true

    # Enable spring loading for all Dock items
    defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

    # Show indicator lights for open applications in the Dock
    defaults write com.apple.dock show-process-indicators -bool true

    # Automatically hide and show the Dock
    defaults write com.apple.dock autohide -bool true

    # Remove the auto-hiding Dock delay
    defaults write com.apple.dock autohide-delay -float 0

    # Remove the animation when hiding/showing the Dock
    defaults write com.apple.dock autohide-time-modifier -float 0

    # Make Dock icons of hidden applications translucent
    defaults write com.apple.dock showhidden -bool true

    success "Dock configured"
}

# Finder settings
configure_finder() {
    info "Configuring Finder settings..."

    # Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
    defaults write com.apple.finder QuitMenuItem -bool true

    # Show icons for hard drives, servers, and removable media on the desktop
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

    # Finder: show hidden files by default
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Finder: show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Finder: show status bar
    defaults write com.apple.finder ShowStatusBar -bool true

    # Finder: show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Display full POSIX path as Finder window title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Use list view in all Finder windows by default
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    # Disable the warning before emptying the Trash
    defaults write com.apple.finder WarnOnEmptyTrash -bool false

    success "Finder configured"
}

# Configure keyboard and input settings
configure_input() {
    info "Configuring keyboard and input settings..."

    # Enable full keyboard access for all controls
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

    # Set a blazingly fast keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 10

    # Disable press-and-hold for keys in favor of key repeat
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    # Disable automatic capitalization
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

    # Disable smart dashes
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    # Disable automatic period substitution
    defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

    # Disable smart quotes
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    success "Input settings configured"
}

# Configure trackpad settings
configure_trackpad() {
    info "Configuring trackpad settings..."

    # Trackpad: enable tap to click for this user and for the login screen
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # Trackpad: map bottom right corner to right-click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

    success "Trackpad configured"
}

# Configure Safari settings
configure_safari() {
    info "Configuring Safari settings..."

    # Privacy: don't send search queries to Apple
    defaults write com.apple.Safari UniversalSearchEnabled -bool false
    defaults write com.apple.Safari SuppressSearchSuggestions -bool true

    # Show the full URL in the address bar
    defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

    # Set Safari's home page to `about:blank`
    defaults write com.apple.Safari HomePage -string "about:blank"

    # Prevent Safari from opening 'safe' files automatically after downloading
    defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

    # Enable the Develop menu and the Web Inspector in Safari
    defaults write com.apple.Safari IncludeDevelopMenu -bool true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

    success "Safari configured"
}

# Configure Terminal settings
configure_terminal() {
    info "Configuring Terminal settings..."

    # Only use UTF-8 in Terminal.app
    defaults write com.apple.terminal StringEncodings -array 4

    # Enable Secure Keyboard Entry in Terminal.app
    defaults write com.apple.terminal SecureKeyboardEntry -bool true

    success "Terminal configured"
}

# Configure screen capture settings
configure_screen_capture() {
    info "Configuring screen capture settings..."

    # Save screenshots to the desktop
    defaults write com.apple.screencapture location -string "${HOME}/Desktop"

    # Save screenshots in PNG format
    defaults write com.apple.screencapture type -string "png"

    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true

    success "Screen capture configured"
}

# Configure Activity Monitor
configure_activity_monitor() {
    info "Configuring Activity Monitor..."

    # Show the main window when launching Activity Monitor
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

    # Visualize CPU usage in the Activity Monitor Dock icon
    defaults write com.apple.ActivityMonitor IconType -int 5

    # Show all processes in Activity Monitor
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    # Sort Activity Monitor results by CPU usage
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0

    success "Activity Monitor configured"
}

# Restart affected applications
restart_applications() {
    info "Restarting affected applications..."

    for app in "Activity Monitor" \
        "cfprefsd" \
        "Dock" \
        "Finder" \
        "Safari" \
        "SystemUIServer"; do
        if pgrep "$app" >/dev/null; then
            killall "$app" &> /dev/null || true
        fi
    done

    success "Applications restarted"
}

# Main execution
main() {
    echo "🍎 macOS System Configuration"
    echo "============================"

    warning "This script will modify your macOS system preferences."
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi

    close_system_preferences
    set_general_settings
    configure_dock
    configure_finder
    configure_input
    configure_trackpad
    configure_safari
    configure_terminal
    configure_screen_capture
    configure_activity_monitor
    restart_applications

    success "macOS configuration complete!"
    warning "Some changes require a logout/restart to take effect."
}

main "$@"