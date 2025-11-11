{
  description = "A simple NixOS flakes";

  outputs = {
    flake-parts,
    flake-utils,
    home-manager,
    treefmt-nix,
    nixpkgs,
    ...
  } @ inputs: let
    nixpkgs-lib = nixpkgs.lib;
    lib = nixpkgs-lib.extend (import ./lib);
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
        systems = flake-utils.lib.defaultSystems;
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
              ];
          };
        };
      }
    );

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "github:NixOS/nixpkgs/master";

    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module?ref=release-2.93";
      # url = "git+https://git.lix.systems/lix-project/nixos-module";
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
    };

    flake-utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
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
      ref = "v0.4.3";
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

    quickshell = {
      type = "github";
      owner = "outfoxxed";
      repo = "quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      type = "github";
      owner = "noctalia-dev";
      repo = "noctalia-shell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        quickshell.follows = "quickshell";
      };
    };
  };
}
