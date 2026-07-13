{
  description = "Dev VM tool profile";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Custom binary script to run your complete update cycle
          nix-up = pkgs.writeShellScriptBin "nix-up" ''
            set -euo pipefail

            echo "[nix-up] Updating dotfiles repo"
            git -C ~/dotfiles pull --ff-only

            echo "[nix-up] Updating global system utilities profile..."
            NIXPKGS_ALLOW_UNFREE=1 nix profile upgrade \
                --impure \
                dotfiles

            echo "[nix-up] Environment successfully updated!"
          '';
        in
        {
          default = pkgs.buildEnv {
            name = "global-devenv-tools";
            paths = with pkgs; [
              helix
              neovim
              claude-code
              fzf
              ripgrep
              zoxide
              tree-sitter
              zsh
              fnm
              asdf-vm
              awscli2
              kubectl
              kustomize
              kubernetes-helm
              helmfile
              k3d
              nix-up
              doppler

              # LSPs
              stylua
              oxfmt
              oxlint
              tsgolint
              typescript-language-server
              python314Packages.jedi-language-server
              python314Packages.mypy
              python314Packages.flake8

              go
              gopls
              golangci-lint
              golangci-lint-langserver
            ];
          };
        }
      );
    };
}
