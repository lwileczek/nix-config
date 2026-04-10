{
  description = "Project flake starter";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Optional language-specific modules
        lib.modules.go   = import ./modules/go.nix   { inherit pkgs; };
        lib.modules.js   = import ./modules/js.nix   { inherit pkgs; };
        lib.modules.rust = import ./modules/rust.nix { inherit pkgs; };

        # reusable library function
        lib.mkShell = { 
                pkgs ? nixpkgs.legacyPackages.${system}
                , deps ? []
                , env         ? {}
                , shCmd ? ""
                , modules ? []  # List of module names to enable, e.g., [ "go" "js" ]
        }: 
          let
            # Helper to get packages for a module name using attrset lookup
            getModulePkgs = name: 
              {
                go   = self.lib.${system}.modules.go;
                js   = self.lib.${system}.modules.js;
                rust = self.lib.${system}.modules.rust;
              }.${name} or [];
            # Collect all module packages
            modulePkgs = builtins.concatLists (map getModulePkgs modules);
          in
          pkgs.mkShell {
          buildInputs = with pkgs; [
            opencode # AI buddy
            rtk # reduce tokens sent to opencode

            # SCM
            git     # SourceControlManager
            gnupg   # To sign commits
            openssh # Connect to git over ssh
            openssl # Certs 'n things

            # Developer preferences
            eza     # Add color to LS
            bat     # Colored replacement for cat
            ripgrep # grep but don't check hidden dirs
            fzf     # fuzzy text search
            fd      # Fast file finder
            just    # Task runner

            # Common CLI Utils
            jq      # JSON parser
            wget    # web file fetcher
            curl    # web file fetcher
            less    # View fiels
            unzip   # unzip files
            bash-completion # to enable autocomplete when a shell is started
          ] ++ modulePkgs ++ deps;

          # Take environment variables from downstream
          inherit env;

          # If not set downstream, default these values here
          EDITOR      = env.EDITOR or "vim";

          shellHook = ''
            alias ls='eza --icons --colour'
            alias cat='bat'
            export GPG_TTY=$(tty)
            source ${pkgs.bash-completion}/etc/profile.d/bash_completion.sh

            parse_git_branch() {
                git rev-parse --is-inside-work-tree &>/dev/null || return
                branch=$(git symbolic-ref --short HEAD 2>/dev/null)
                status=$(git status --porcelain 2>/dev/null)
                dirty=""
                [[ -n "$status" ]] && dirty="*"
                echo "($branch$dirty)"
            }

            PS1="\t (\[\e[1;31m\]jobs:\j\e[0m) \
            \[\e[38;5;160m\]$(if [[ $? != 0 ]]; then echo "✘"; fi)\[\e[0m\] \
            \[\e[38;5;33m\]\w\[\e[0m\] \
            \[\e[38;5;178m\]\$(parse_git_branch)\[\e[0m\]\n\$ "

            echo "Hello, World. Global aliases loaded."
          '' + shCmd;
        };

        # concrete shell for this repo
        devShells.default = self.lib.${system}.mkShell { };
      });
}
