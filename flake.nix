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

            echo "[nix-up] Updating global system utilities profile..."
            sudo nix profile install ~/dotfiles#default --profile /nix/var/nix/profiles/default

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
            ];
          };
        }
      );

      homeConfigurations."marek" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux"; 
        modules = [
          meridian.homeManagerModules.default
          ({ config, pkgs, ... }: {
            home = {
              username = "marek";
              homeDirectory = "/home/marek";
              stateVersion = "24.11"; 

              sessionVariables = {
                ANTHROPIC_BASE_URL = "http://127.0.0.1:3456";
                ANTHROPIC_API_KEY = "dummy";
              };
            };

            services.meridian = {
              enable = true;
              settings = {
                port = 3456;
                host = "127.0.0.1";
              };
            };

            xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
              plugin = [ config.services.meridian.opencode.pluginPath ];
            };

            systemd.user.services.opencode-serve = {
              Unit = {
                Description = "OpenCode Serve Daemon";
                After = [ "meridian.service" ];
                Requires = [ "meridian.service" ];
              };

              Service = {
                ExecStart = "${pkgs.writeShellScript "start-opencode-serve" ''
                  export PATH="$PATH:/usr/bin:/usr/local/bin:/snap/bin"
                  exec opencode serve
                ''}";

                Restart = "on-failure";
                RestartSec = 5;

                Environment = [
                  "ANTHROPIC_BASE_URL=http://127.0.0.1:3456"
                  "ANTHROPIC_API_KEY=dummy"
                ];
              };

              Install = {
                WantedBy = [ "default.target" ];
              };
            };

            # Automatically hot-swaps active background configurations when switching the flake
            systemd.user.startServices = "sd-switch";
          })
        ];
      };
    };
}
