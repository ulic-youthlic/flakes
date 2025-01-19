{
  description = "A simple NixOS flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    helix = {
      url = "github:helix-editor/helix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    oskars-dotfiles = {
      url = "github:oskardotglobal/.dotfiles/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-flake = {
      url = "github:sodiboo/niri-flake";
    };

    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    dae = {
      url = "github:daeuniverse/flake.nix";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    nur-xddxdd = {
      url = "github:xddxdd/nur-packages?ref=master&dir=/pkgs/uncategorized";
      flake = false;
    };

    firefox-addons = {
      url = "git+https://gitlab.com/rycee/nur-expressions.git?dir=pkgs/firefox-addons&ref=master";
      flake = false;
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      flake-utils,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      rootPath = ./.;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = flake-utils.lib.defaultSystems;
      perSystem = (
        { pkgs, system, ... }@args:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
            };
          };
          packages = import ./pkgs (
            args
            // {
              inherit inputs;
            }
          );
        }
      );
      flake =
        {
          nix.settings = {
            # substituters shared in home-manager and nixos configuration
            substituters =
              let
                channelStore = x: "https://${x}/nix-channels/store";
                mirrors = map (x: channelStore "mirrors.${x}.edu.cn") [
                  "bfsu"
                  "tuna.tsinghua"
                  "ustc"
                ];
                cachix = x: "https://${x}.cachix.org";
              in
              nixpkgs.lib.flatten [
                mirrors
                (cachix "nix-community")
                "https://cache.nixos.org"
                (cachix "cosmic")
              ];
          };

          nixosModules.default = import ./nixos/modules;

          overlays = {
            modifications = (import ./overlays/modifications { inherit inputs outputs; });
            additions = (import ./overlays/additions { inherit inputs outputs; });
          };

          nixosConfigurations =
            let
              nixosConfigDir = ./nixos/configurations;
            in
            nixpkgs.lib.genAttrs
              (map (f: nixpkgs.lib.removeSuffix ".nix" f) (builtins.attrNames (builtins.readDir nixosConfigDir)))
              (
                hostName:
                nixpkgs.lib.nixosSystem {
                  modules =
                    [
                      outputs.nixosModules.default
                    ]
                    ++ [
                      (
                        let
                          dirPath = nixosConfigDir + "/${hostName}";
                          filePath = nixosConfigDir + "/${hostName}.nix";
                        in
                        if builtins.pathExists dirPath then dirPath else filePath
                      )
                    ];
                  specialArgs = {
                    inherit inputs outputs rootPath;
                  };
                }
              );
        }
        // (
          let
            mkHomeConfig =
              {
                hostName,
                unixName ? "david",
                system ? "x86_64-linux",
                nixpkgs ? inputs.nixpkgs,
                home-manager ? inputs.home-manager,
              }:
              {
                "${unixName}@${hostName}" = home-manager.lib.homeManagerConfiguration {
                  pkgs = nixpkgs.legacyPackages."${system}";
                  modules =
                    [
                      (./home + "/${unixName}/configurations/${hostName}")
                    ]
                    ++ (with outputs.homeManagerModules; [
                      default
                      "${unixName}"
                    ])
                    ++ (with inputs; [
                      stylix.homeManagerModules.stylix
                    ]);
                  extraSpecialArgs = {
                    inherit
                      inputs
                      outputs
                      unixName
                      hostName
                      system
                      rootPath
                      ;
                  };
                };
              };
          in
          {
            homeConfigurations = nixpkgs.lib.foldr (a: b: a // b) { } (
              map (hostName: mkHomeConfig { inherit hostName; }) [
                "Tytonidae"
                "Akun"
              ]
            );
            homeManagerModules =
              {
                default = import ./home/modules;
              }
              // (
                let
                  allEntries = builtins.readDir ./home;
                  allUsers = nixpkgs.lib.filterAttrs (
                    key: value: value == "directory" && key != "modules"
                  ) allEntries;
                in
                builtins.listToAttrs (
                  map (name: {
                    name = name;
                    value = import (./home + "/${name}/modules");
                  }) (builtins.attrNames allUsers)
                )
              );
          }
        );
    };
}
