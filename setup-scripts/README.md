# Setup Scripts

This directory contains automated setup scripts for different development environments and time periods.

## 📁 Directory Structure

Each setup is organized by purpose and date to track evolution of the development environment:

```
setup-scripts/
├── work-laptop-december-2025/     # Latest work laptop setup (December 2025)
│   ├── homebrew-packages.sh       # Software installation via Homebrew
│   ├── development-tools.sh       # Development environment setup
│   ├── macos-settings.sh          # macOS system preferences
│   └── README.md                  # Detailed documentation
└── README.md                      # This file
```

## 🚀 Quick Start

For the latest work laptop setup (December 2025):

```bash
cd ~/.dotfiles/setup-scripts/work-laptop-december-2025

# Install software packages
./homebrew-packages.sh

# Setup development environments
./development-tools.sh

# Configure macOS system preferences
./macos-settings.sh
```

## 📅 Setup Versions

### Work Laptop December 2025
**Current/Latest Setup**

Based on analysis of ryenbeatty's macOS development machine circa December 2025.

**Highlights:**
- 25+ essential CLI tools (cleaned of duplicates and dependencies)
- 30+ GUI applications via Homebrew Cask
- Mac App Store apps automation
- Multi-language development setup (Node.js, Python, Rust, Go, Java)
- Comprehensive macOS system preferences optimization
- 100+ manually installable applications cataloged

See `work-laptop-december-2025/README.md` for complete details.

## 🔄 Future Setups

Future setup scripts will be added as new versions with appropriate dating:
- `work-laptop-january-2026/` - Next iteration
- `personal-laptop-2026/` - Personal machine setup
- `server-setup-2026/` - Server configuration scripts

## 🛠️ Usage Philosophy

Each setup version is:
- **Complete** - Can set up a machine from scratch
- **Idempotent** - Safe to run multiple times
- **Documented** - Clear instructions and package listings
- **Audited** - Removes duplicates, dependencies, and default software

## 📝 Contributing

When creating new setup versions:

1. **Date the directory** - Use clear naming like `purpose-month-year`
2. **Document thoroughly** - Include README with full package listings
3. **Audit packages** - Remove defaults, dependencies, and duplicates
4. **Test carefully** - Verify on clean systems when possible
5. **Maintain separation** - Each version should be self-contained

## 🔍 Package Auditing Guidelines

When creating setup scripts, remove:

- **macOS defaults**: curl, zip, unzip, zsh, python, sqlite
- **Homebrew dependencies**: autoconf, automake, pkg-config, openssl, etc.
- **Duplicates**: Multiple ways to install the same tool
- **Unused libraries**: System libraries not directly needed

Focus on **top-level tools** that developers actually invoke directly.