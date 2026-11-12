# rust
# rustup owns the toolchain, and this one directory is the whole story: it holds
# the shims that matter (`cargo`, `rustc`, `rustup`, `rustfmt`, `clippy-driver`)
# and it is where every `cargo install <crate>` puts its binary. Nothing else on
# this machine installs Rust -- the Homebrew formula and mise are deliberately not
# used (see the runtime table in README.md), so there is no second copy to shadow.
export PATH="$HOME/.cargo/bin:$PATH"

# CARGO_HOME / RUSTUP_HOME are left at their defaults on purpose: ~/.rustup holds
# the toolchains, and rust/install.sh assumes those two paths when it calls
# ~/.cargo/bin/rustup (this file only runs in interactive shells, so it cannot be
# relied on during an install).
