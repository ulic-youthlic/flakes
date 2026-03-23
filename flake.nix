{
  description = "A simple NixOS flakes";

  outputs = {
    flake-parts,
    home-manager,
    treefmt-nix,
    nixpkgs,
    nixpkgs-patcher,
    ...
  } @ inputs: let
    nixpkgs-lib = nixpkgs.lib;
    lib = nixpkgs-lib.extend (final: prev: nixpkgs-lib.recursiveUpdate {nixpkgs-patcher = nixpkgs-patcher.lib;} (import ./lib final prev));
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
      {lib, ...}: {
        systems = ["x86_64-linux"];
        imports =
          [
            home-manager.flakeModules.home-manager
            treefmt-nix.flakeModule
          ]
          ++ lib.youthlic.loadImports ./flake;
        flake = {
          inherit lib;
          nix.settings = {
            # substituters shared in home-manager and nixos configuration
            substituters = let
              cachix = x: "https://${x}.cachix.org";
            in
              lib.flatten [
                (cachix "nix-community")
                "https://cache.nixos.org"
                "https://cache.nixos-cuda.org"
                "https://attic.xuyh0120.win/lantian"
                "https://cache.garnix.io"
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

    nix-cachyos-kernel = {
      type = "github";
      owner = "xddxdd";
      repo = "nix-cachyos-kernel";
    };

    helix = {
      type = "github";
      owner = "helix-editor";
      repo = "helix";
      ref = "master";
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

    nixvim = {
      type = "github";
      owner = "nix-community";
      repo = "nixvim";
    };
    neovim-nightly = {
      type = "github";
      owner = "nix-community";
      repo = "neovim-nightly-overlay";
    };
    nvchad-starter = {
      type = "github";
      owner = "ulic-youthlic";
      repo = "nvchad-starter";
      flake = false;
    };
    nix4nvchad = {
      type = "github";
      owner = "nix-community";
      repo = "nix4nvchad";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nvchad-starter.follows = "nvchad-starter";
      };
    };

    lanzaboote = {
      type = "github";
      owner = "nix-community";
      repo = "lanzaboote";
      ref = "v1.0.0";
    };

    nix-doom = {
      type = "github";
      owner = "marienz";
      repo = "nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spacemacs = {
      type = "github";
      owner = "syl20bnr";
      repo = "spacemacs";
      flake = false;
    };
    emacs-overlay = {
      type = "github";
      owner = "nix-community";
      repo = "emacs-overlay";
    };

    nix-gaming = {
      type = "github";
      owner = "fufexan";
      repo = "nix-gaming";
    };

    noctalia = {
      type = "github";
      owner = "noctalia-dev";
      repo = "noctalia-shell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    spicetify-nix = {
      type = "github";
      owner = "Gerg-L";
      repo = "spicetify-nix";
    };

    dae-flake = {
      type = "github";
      owner = "daeuniverse";
      repo = "flake.nix";
    };
  };
}
