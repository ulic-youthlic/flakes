{
  description = "A simple NixOS flakes";

  outputs = {
    nixpkgs,
    flake-parts,
    flake-utils,
    home-manager,
    treefmt-nix,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = flake-utils.lib.defaultSystems;
      imports = [
        home-manager.flakeModules.home-manager
        treefmt-nix.flakeModule

        ./flake
      ];
      flake = {
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
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "github:NixOS/nixpkgs/master";
    # nixpkgs.follows = "nixos-cosmic/nixpkgs";

    nixpkgs-hurl = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "refs/pull/418842/head";
    };

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
      owner = "nix-community";
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

    chaotic = {
      type = "github";
      owner = "chaotic-cx";
      repo = "nyx";
    };
  };
}
