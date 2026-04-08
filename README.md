# Nix Starter Flake

A reusable Nix flake providing a base development environment shell. This serves as a foundation for new projects, eliminating the need to duplicate common tool configurations across repositories.

## Overview

This flake defines a `mkShell` library function that creates development shells with a consistent set of base tools. Projects can extend this base configuration by adding project-specific dependencies, environment variables, and shell hooks.

## Features

### Included Tools

| Category | Tools |
|----------|-------|
| **AI Assistant** | `opencode` - AI coding buddy, `rtk` - token reduction utility |
| **Source Control** | `git`, `gnupg` (commit signing), `openssh`, `openssl` |
| **Modern CLI Replacements** | `eza` (colorful `ls`), `bat` (syntax-highlighted `cat`), `ripgrep`, `fzf`, `fd` |
| **Task Runner** | `just` |
| **Utilities** | `jq`, `wget`, `curl`, `less`, `unzip`, `bash-completion` |

### Optional Modules

Optional language-specific modules are located in the `modules/` directory:

| Module | Tools | Import Path |
|--------|-------|-------------|
| **Go** | `go`, `gopls`, `revive`, `gofumpt` | `base.lib.${system}.modules.go` |
| **JavaScript/TypeScript** | `bun`, `biome`, `typescript-go` | `base.lib.${system}.modules.js` |

### Shell Enhancements

- **Colored `ls`** via `eza --icons --colour`
- **Syntax-highlighted `cat`** via `bat`
- **Git-aware prompt** showing current branch and dirty state
- **Exit status indicator** (✘ on non-zero exit)
- **Background job count** in prompt
- **GPG TTY configuration** for commit signing
- **Bash completion** enabled

## Usage

### As a Standalone Shell

Enter the development shell:

```bash
nix develop
```

### Optional Language Modules

This flake provides optional language-specific package sets that can be enabled via the `modules` parameter or composed manually.

#### Enabling Modules (Recommended)

Use the `modules` parameter to enable modules by name:

```nix
{
  devShells.default = base.lib.${system}.mkShell {
    modules = [ "go" "js" ];  # Enable Go and JavaScript/TypeScript modules
    
    deps = with pkgs; [ 
      # Additional project-specific packages
    ];
  };
}
```

**Available modules:**
- `"go"` - Go development tools
- `"js"` - JavaScript/TypeScript development tools (Bun, Biome, TypeScript-Go)

**Enable only specific modules:**

```nix
# Go only
modules = [ "go" ];

# JavaScript/TypeScript only
modules = [ "js" ];

# Both
modules = [ "go" "js" ];

# No modules (base tools only)
modules = [];
```

#### Manual Module Composition

Alternatively, you can manually compose modules with your deps (old approach):

```nix
{
  devShells.default = base.lib.${system}.mkShell {
    deps = base.lib.${system}.modules.go ++ base.lib.${system}.modules.js;
  };
}
```

#### Go Module (`lib.modules.go`)

Includes Go toolchain and development tools:

| Tool | Description |
|------|-------------|
| `go` | Go compiler and toolchain |
| `gopls` | Go language server (LSP) |
| `revive` | Fast, configurable linter |
| `gofumpt` | Stricter gofmt formatter |

**Usage in your project flake:**

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    base.url = "github:yourusername/nix-starter"; # or path:/path/to/this/flake
  };

  outputs = { self, nixpkgs, flake-utils, base }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = base.lib.${system}.mkShell {
          # Enable Go module
          modules = [ "go" ];

          deps = with pkgs; [ 
            # Add other project-specific packages here
          ];

          env = {
            GO111MODULE = "on";
          };

          shCmd = ''
            echo "Go version: $(go version)"
          '';
        };
      });
}
```

#### JavaScript/TypeScript Module (`lib.modules.js`)

Fast JavaScript/TypeScript toolchain powered by Bun and Rust-based tools:

| Tool | Description | Command Examples |
|------|-------------|------------------|
| `bun` | Fast JS/TS runtime, package manager, bundler, test runner | `bun install`, `bun run`, `bun test`, `bun build` |
| `biome` | All-in-one linter, formatter, import organizer | `biome check .`, `biome format --write .`, `biome lint .` |
| `typescript-go` | Blazing fast type checker (Go port of tsc) | `tsc-go --noEmit` |

**Usage in your project flake:**

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    base.url = "github:yourusername/nix-starter"; # or path:/path/to/this/flake
  };

  outputs = { self, nixpkgs, flake-utils, base }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = base.lib.${system}.mkShell {
          # Enable JavaScript/TypeScript module
          modules = [ "js" ];

          env = {
            NODE_ENV = "development";
          };

          shCmd = ''
            echo "Bun version: $(bun --version)"
            echo "TypeScript-Go available: $(tsc-go --version 2>/dev/null || echo 'n/a')"
          '';
        };
      });
}
```

### As a Base for Project Flakes

Reference this flake as an input and use the `mkShell` function:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    base.url = "github:yourusername/nix-starter"; # or path:/path/to/this/flake
  };

  outputs = { self, nixpkgs, flake-utils, base }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = base.lib.${system}.mkShell {
          # Add project-specific packages
          deps = with pkgs; [ nodejs python3 ];

          # Set environment variables
          env = {
            NODE_ENV = "development";
            EDITOR = "nvim";
          };

          # Add shell commands/hooks
          shCmd = ''
            echo "Project-specific setup complete!"
            just --list 2>/dev/null || true
          '';
        };
      });
}
```

### Adding New Modules

To add a new language module:

1. **Create a new file** in `modules/` (e.g., `modules/rust.nix`):

```nix
{ pkgs }:

with pkgs; [
  rustc
  cargo
  rustfmt
  clippy
]
```

2. **Expose it in `flake.nix`** by adding to the `lib.modules` attribute:

```nix
lib.modules.rust = import ./modules/rust.nix { inherit pkgs; };
```

3. **Register the module name** in the `getModulePkgs` function within `lib.mkShell`:

```nix
getModulePkgs = name: 
  {
    go = self.lib.${system}.modules.go;
    js = self.lib.${system}.modules.js;
    rust = self.lib.${system}.modules.rust;  # Add this line
  }.${name} or [];
```

4. **Use it in your project** via `modules = [ "rust" ];`

## `mkShell` API

The `mkShell` function accepts the following optional parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `pkgs` | attrset | `nixpkgs.legacyPackages.${system}` | Package set to use |
| `deps` | list | `[]` | Additional packages to include |
| `env` | attrset | `{}` | Environment variables to set |
| `shCmd` | string | `""` | Additional shell commands appended to shellHook |
| `modules` | list of strings | `[]` | Language modules to enable: `"go"`, `"js"` |

### Default Environment Variables

- `EDITOR` - Defaults to `"vim"` unless overridden in `env`

## Inputs

| Input | Source |
|-------|--------|
| `nixpkgs` | `github:NixOS/nixpkgs/nixos-unstable` |
| `flake-utils` | `github:numtide/flake-utils` |

## License

Unlicensed - Use as you wish for your own projects.
