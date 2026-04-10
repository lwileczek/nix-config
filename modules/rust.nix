# Rust development environment module
# This file provides Rust-specific tools that can be composed with the base shell

{ pkgs }:

with pkgs; [
  rustc          # Rust compiler
  cargo          # Build system and package manager
  rust-analyzer  # Rust language server (LSP)
  clippy         # Linter (cargo clippy)
  rustfmt        # Formatter (cargo fmt)
  cargo-watch    # Re-run commands on file changes
  cargo-audit    # Audit Cargo.lock for known CVEs
  cargo-nextest  # Fast, feature-rich test runner
]
