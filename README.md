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
| **Rust** | `rustc`, `cargo`, `rust-analyzer`, `clippy`, `rustfmt`, `cargo-watch`, `cargo-audit`, `cargo-nextest` | `base.lib.${system}.modules.rust` |

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
- `"rust"` - Rust development tools

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
    # Share YOUR nixpkgs with base: one nixpkgs for base tools, modules, and your deps
    base = {
      url = "github:lwileczek/nix-config"; # or path:/path/to/this/flake
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    # Share YOUR nixpkgs with base: one nixpkgs for base tools, modules, and your deps
    base = {
      url = "github:lwileczek/nix-config"; # or path:/path/to/this/flake
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

#### Rust Module (`lib.modules.rust`)

Rust toolchain with LSP, lint/format, and cargo add-ons:

| Tool | Description |
|------|-------------|
| `rustc` | Rust compiler |
| `cargo` | Build system and package manager |
| `rust-analyzer` | Rust language server (LSP) |
| `clippy` | Linter (`cargo clippy`) |
| `rustfmt` | Formatter (`cargo fmt`) |
| `cargo-watch` | Re-run commands when files change |
| `cargo-audit` | Audit `Cargo.lock` for known CVEs |
| `cargo-nextest` | Fast, feature-rich test runner |

**Usage in your project flake:**

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    base = {
      url = "github:lwileczek/nix-config"; # or path:/path/to/this/flake
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, base }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = base.lib.${system}.mkShell {
          # Enable Rust module
          modules = [ "rust" ];

          env = {
            RUST_LOG = "debug";
          };

          shCmd = ''
            echo "Rust version: $(rustc --version)"
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
    # Share YOUR nixpkgs with base: one nixpkgs for base tools, modules, and your deps
    base = {
      url = "github:lwileczek/nix-config"; # or path:/path/to/this/flake
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

### Keeping Packages Fresh (`follows`)

Every example above sets `inputs.nixpkgs.follows = "nixpkgs"` on the `base` input. This is the recommended setup, and knowing what it does helps you keep packages current:

- **Without `follows`**: `base` falls back to the nixpkgs revision recorded in *this repo's* committed `flake.lock`. Every tool it provides (`opencode`, `eza`, `go`, `rustc`, ...) then comes from the state of this repo when its lock was last committed — not from your `nixpkgs`. Your project also ends up evaluating two different nixpkgs: `base`'s for its tools, yours for `deps`.
- **With `follows`**: a single nixpkgs — yours — feeds everything: the base tool list, the language modules, and your `deps`. Your project's `flake.lock` becomes the one source of truth for tool versions.

To pick up the latest packages, update your project's lock file:

| Command | Updates |
|---------|---------|
| `nix flake update nixpkgs` | All package versions: base tools, modules, and your `deps` |
| `nix flake update base` | This repo's code: tool list, `shellHook`, `modules/*.nix` |
| `nix flake update` | Both |

Notes:

- The `follows` target refers to your own input name, so keep your flake's input named `nixpkgs`.
- Commit your project's `flake.lock` — it stays reproducible until you update it explicitly. For updates without remembering, run `nix flake update` on a schedule (cron/CI/Renovate).
- Optional: also set `inputs.flake-utils.follows = "flake-utils";` on `base` to share a single copy of `flake-utils` (cosmetic only).

### Adding New Modules

To add a new language module (this example adds `python.nix`; `go`, `js`, and `rust` already exist):

1. **Create a new file** in `modules/` (e.g., `modules/python.nix`):

```nix
{ pkgs }:

with pkgs; [
  python3
  uv
  ruff
]
```

2. **Expose it in `flake.nix`** by adding to the `lib.modules` attribute:

```nix
lib.modules.python = import ./modules/python.nix { inherit pkgs; };
```

3. **Register the module name** in the `getModulePkgs` function within `lib.mkShell`:

```nix
getModulePkgs = name: 
  {
    go = self.lib.${system}.modules.go;
    js = self.lib.${system}.modules.js;
    rust = self.lib.${system}.modules.rust;
    python = self.lib.${system}.modules.python;  # Add this line
  }.${name} or [];
```

4. **Use it in your project** via `modules = [ "python" ];`

## `mkShell` API

The `mkShell` function accepts the following optional parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `pkgs` | attrset | `nixpkgs.legacyPackages.${system}` | Package set to use |
| `deps` | list | `[]` | Additional packages to include |
| `env` | attrset | `{}` | Environment variables to set |
| `shCmd` | string | `""` | Additional shell commands appended to shellHook |
| `modules` | list of strings | `[]` | Language modules to enable: `"go"`, `"js"`, `"rust"` |

### Default Environment Variables

- `EDITOR` - Defaults to `"vim"` unless overridden in `env`

## Inputs

| Input | Source |
|-------|--------|
| `nixpkgs` | `github:NixOS/nixpkgs/nixos-unstable` |
| `flake-utils` | `github:numtide/flake-utils` |

Projects consuming this flake should follow their own `nixpkgs` via `base.inputs.nixpkgs.follows = "nixpkgs"` — see [Keeping Packages Fresh (`follows`)](#keeping-packages-fresh-follows).
