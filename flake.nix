{
  description = "A simple NixOS flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "github:NixOS/nixpkgs/master";
    # nixpkgs.follows = "nixos-cosmic/nixpkgs";

    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module?ref=release-2.93";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    helix = {
      type = "github";
      owner = "helix-editor";
      repo = "helix";
      ref = "master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    betterfox-nix = {
      type = "github";
      owner = "HeitorAugustoLN";
      repo = "betterfox-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    niri-flake = {
      type = "github";
      owner = "sodiboo";
      repo = "niri-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixos-cosmic = {
      type = "github";
      owner = "lilyinstarlight";
      repo = "nixos-cosmic";
    };

    nixos-hardware = {
      type = "github";
      owner = "NixOS";
      repo = "nixos-hardware";
      ref = "master";
    };

    dae = {
      type = "github";
      owner = "daeuniverse";
      repo = "flake.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    flake-parts = {
      type = "github";
      owner = "hercules-ci";
      repo = "flake-parts";
    };

    flake-utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
    };

    nur-rycee = {
      type = "gitlab";
      owner = "rycee";
      repo = "nur-expressions";
      ref = "master";
      flake = false;
    };

    sops-nix = {
      type = "github";
      owner = "Mic92";
      repo = "sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    stylix = {
      type = "github";
      owner = "danth";
      repo = "stylix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        home-manager.follows = "home-manager";
      };
    };

    disko = {
      type = "github";
      owner = "nix-community";
      repo = "disko";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    deploy-rs = {
      type = "github";
      owner = "serokell";
      repo = "deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
    };

    treefmt-nix = {
      type = "github";
      owner = "numtide";
      repo = "treefmt-nix";
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-parts,
    flake-utils,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} ({flake-parts-lib, ...}: let
      inherit (self) outputs;
      inherit (flake-parts-lib) importApply;
      rootPath = ./.;
      nixos = importApply ./flake/nixos.nix {inherit rootPath outputs;};
      home = importApply ./flake/home.nix {inherit rootPath outputs;};
      deploy = importApply ./flake/deploy.nix {inherit outputs;};
      templates = importApply ./flake/templates.nix {inherit rootPath;};
    in {
      systems = flake-utils.lib.defaultSystems;
      imports = [
        inputs.home-manager.flakeModules.home-manager
        inputs.treefmt-nix.flakeModule
        nixos
        home
        deploy
        templates
      ];
      perSystem = {
        pkgs,
        system,
        ...
      } @ args: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
        packages = import ./pkgs (
          args
          // {
            inherit inputs rootPath;
          }
        );
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nixd
            typos
            typos-lsp
            just
            nvfetcher
          ];
        };
        treefmt = {
          programs = {
            alejandra = {
              enable = true;
              excludes = ["pkgs/_sources/*.nix"];
            };
            biome = {
              enable = true;
              includes = ["*.json"];
              excludes = ["pkgs/_sources/*.json"];
              settings = {
                javascript.formatter.enabled = false;
                css.formatter.enabled = false;
              };
            };
            dprint = {
              enable = true;
              includes = ["*.md" "*.toml" "*.yaml"];
              excludes = ["secrets/*.yaml"];
              settings = {
                plugins = pkgs.dprint-plugins.getPluginList (plugins:
                  with plugins; [
                    dprint-plugin-toml
                    dprint-plugin-markdown
                    g-plane-pretty_yaml
                  ]);
              };
            };
            just = {
              enable = true;
              includes = [".justfile"];
            };
            typos = let
              config = ./.typos.toml |> builtins.readFile |> builtins.fromTOML;
            in {
              enable = true;
              includes = ["*"];
              excludes = ["assets/*"] ++ config.files.extend-exclude;
              configFile = "${toString ./.typos.toml}";
              # Disable all extra option in treefmt module.
              # Use config file.
              sort = false;
              isolated = false;
              hidden = false;
              noIgnore = false;
              noIgnoreDot = false;
              noIgnoreGlobal = false;
              noIgnoreParent = false;
              noIgnoreVCS = false;
              binary = false;
              noCheckFilenames = false;
              noCheckFiles = false;
              noUnicode = false;
            };
          };
        };
      };
      flake = {
        overlays = {
          modifications = import ./overlays/modifications {inherit inputs outputs;};
          additions = import ./overlays/additions {inherit inputs outputs;};
        };
        nix.settings = {
          # substituters shared in home-manager and nixos configuration
          substituters = let
            cachix = x: "https://${x}.cachix.org";
          in
            nixpkgs.lib.flatten [
              (cachix "nix-community")
              "https://cache.nixos.org"
              (cachix "cosmic")
            ];
        };
      };
    });
}
