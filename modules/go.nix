# Go development environment module
# This file provides Go-specific tools that can be composed with the base shell

{ pkgs }:

with pkgs; [
  go           # Go compiler and toolchain
  gopls        # Go language server (LSP)
  revive       # Fast, configurable linter for Go
  gofumpt      # Stricter gofmt with additional formatting rules
]
