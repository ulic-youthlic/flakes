{
  description = "A simple NixOS flakes";

  outputs =
    {
      flake-parts,
      home-manager,
      treefmt-nix,
      nixpkgs,
      nixpkgs-patcher,
      ...
    }@inputs:
    let
      nixpkgs-lib = nixpkgs.lib;
      lib = nixpkgs-lib.extend (
        final: prev:
        nixpkgs-lib.recursiveUpdate { nixpkgs-patcher = nixpkgs-patcher.lib; } (import ./lib final prev)
      );
    in
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = {
          inherit lib;
          rootPath = ./.;
        };
      }
      (
        { lib, ... }: {
          systems = [ "x86_64-linux" ];
          imports = [
            home-manager.flakeModules.home-manager
            treefmt-nix.flakeModule
          ]
          ++ lib.youthlic.loadImports ./flake;
          flake = {
            inherit lib;
            nix.settings = {
              # substituters shared in home-manager and nixos configuration
              substituters =
                let
                  cachix = x: "https://${x}.cachix.org";
                in
                lib.flatten [
                  (cachix "nix-community")
                  "https://cache.nixos.org"
                  "https://cache.nixos-cuda.org"
                  "https://attic.xuyh0120.win/lantian"
                ];
            };
          };
        }
      );

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "github:NixOS/nixpkgs/master";
    ## update rqbit
    nixpkgs-patch-rqbit-bump = {
      url = "https://github.com/nixos/nixpkgs/pull/485603.diff";
      flake = false;
    };
    nixpkgs-patcher = {
      type = "github";
      owner = "gepbird";
      repo = "nixpkgs-patcher";
    };
    nixpkgs-multiverse = {
      type = "github";
      owner = "fzakaria";
      repo = "nixpkgs-multiverse";
    };

    nix-cachyos-kernel = {
      type = "github";
      owner = "xddxdd";
      repo = "nix-cachyos-kernel";
      inputs.flake-parts.follows = "flake-parts";
    };

    helix = {
      type = "github";
      owner = "mattwparas";
      repo = "helix";
      ref = "steel-event-system";
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    zen-browser = {
      type = "github";
      owner = "0xc000022070";
      repo = "zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
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

    nixos-hardware = {
      type = "github";
      owner = "NixOS";
      repo = "nixos-hardware";
      ref = "master";
    };

    flake-parts = {
      type = "github";
      owner = "hercules-ci";
      repo = "flake-parts";
      inputs."nixpkgs-lib".follows = "nixpkgs";
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
      owner = "nix-community";
      repo = "stylix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
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
      };
    };

    treefmt-nix = {
      type = "github";
      owner = "numtide";
      repo = "treefmt-nix";
    };

    nur = {
      type = "github";
      owner = "nix-community";
      repo = "NUR";
    };

    lanzaboote = {
      type = "github";
      owner = "nix-community";
      repo = "lanzaboote";
      ref = "v1.1.0";
    };

    noctalia = {
      type = "github";
      owner = "noctalia-dev";
      repo = "noctalia-shell";
      ref = "legacy-v4";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    spicetify-nix = {
      type = "github";
      owner = "Gerg-L";
      repo = "spicetify-nix";
    };
  };
}
