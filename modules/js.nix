# JavaScript/TypeScript development environment module
# This file provides JS/TS-specific tools that can be composed with the base shell

{ pkgs }:

with pkgs; [
  bun             # Fast JavaScript runtime, package manager, bundler, and test runner
  nodejs          # Default server side JS runtime, needed for things against my will
  biome           # Fast linter, formatter, and import organizer (Rust-based)
  typescript-go   # Fast TypeScript type checker - Go implementation of tsc (TypeScript 7)
]
