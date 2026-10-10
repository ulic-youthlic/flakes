{
  description = "A simple NixOS flakes";

  outputs =
    { flake-parts, import-tree, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (import-tree.matchNot ".*/flake\\.nix" ./.);

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
    nixpkgs-patch-helix-fix = {
      url = "https://github.com/NixOS/nixpkgs/pull/569589.patch";
      flake = false;
    };

    # Keeps its own nixpkgs: overlays.pinned takes the kernels built
    # against it, which is what the lantian cache serves.
    nix-cachyos-kernel = {
      type = "github";
      owner = "xddxdd";
      repo = "nix-cachyos-kernel";
      ref = "release";
      inputs.flake-parts.follows = "flake-parts";
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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

    nix-kdl = {
      type = "github";
      owner = "Lhcfl";
      repo = "nix-kdl";
    };
    niri = {
      type = "github";
      owner = "niri-wm";
      repo = "niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xwayland-satellite = {
      type = "github";
      owner = "Supreeeme";
      repo = "xwayland-satellite";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      type = "github";
      owner = "NixOS";
      repo = "nixos-hardware";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      type = "github";
      owner = "nix-community";
      repo = "disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      type = "github";
      owner = "serokell";
      repo = "deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      type = "github";
      owner = "numtide";
      repo = "treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      type = "github";
      owner = "nix-community";
      repo = "NUR";
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      type = "github";
      owner = "Gerg-L";
      repo = "spicetify-nix";
    };

    helium-nix = {
      type = "github";
      owner = "tomsch";
      repo = "helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fcitx5-vinput = {
      type = "github";
      owner = "xifan2333";
      repo = "fcitx5-vinput";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      type = "github";
      owner = "catppuccin";
      repo = "nix";
    };

    import-tree = {
      type = "github";
      owner = "denful";
      repo = "import-tree";
    };

    den = {
      type = "github";
      owner = "denful";
      repo = "den";
    };

    den-overlays = {
      type = "github";
      owner = "ulic-youthlic";
      repo = "den-overlays";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
  };
}
