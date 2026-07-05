{
  description = "Dev VM tool profile";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    meridian.url = "github:rynfar/meridian";
  };

  outputs = { self, nixpkgs, home-manager, meridian, ... }:
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
            sudo NIXPKGS_ALLOW_UNFREE=1 nix profile add \
                --impure \
                ~/dotfiles#default \
                --profile /nix/var/nix/profiles/default

            echo "[nix-up] Syncing Home Manager (Meridian & OpenCode services)..."
            nix run github:nix-community/home-manager -- switch --flake ~/dotfiles#"$(whoami)"

            echo "[nix-up] Environment successfully updated!"
          '';
        in
        {
          default = pkgs.buildEnv {
            name = "global-devenv-tools";
            paths = with pkgs; [
              helix
              neovim
              opencode
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
              tailscale

              # LSPs
              stylua
              oxfmt
              tsgolint
              typescript-language-server
              python314Packages.jedi-language-server
              python314Packages.mypy
              python314Packages.flake8
            ];
          };
        }
      );
    };
}
