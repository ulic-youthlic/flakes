{
  description = "A simple NixOS flakes";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.follows = "nixos-cosmic/nixpkgs";
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "7ffd9ae656aec493492b44d0ddfb28e79a1ea25d";
    };

    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      type = "github";
      owner = "helix-editor";
      repo = "helix";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    oskars-dotfiles = {
      type = "github";
      owner = "oskardotglobal";
      repo = ".dotfiles";
      ref = "nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-flake = {
      type = "github";
      owner = "sodiboo";
      repo = "niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-cosmic = {
      type = "github";
      owner = "lilyinstarlight";
      repo = "nixos-cosmic";
    };

    ghostty = {
      type = "github";
      owner = "ghostty-org";
      repo = "ghostty";
      inputs.nixpkgs-unstable.follows = "nixpkgs";
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
      inputs.nixpkgs.follows = "nixpkgs";
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

    nur-xddxdd = {
      type = "github";
      owner = "xddxdd";
      repo = "nur-packages";
      ref = "master";
      flake = false;
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
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      type = "github";
      owner = "danth";
      repo = "stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      type = "github";
      owner = "nix-community";
      repo = "disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bt-tracker = {
      type = "github";
      owner = "XIU2";
      repo = "TrackersListCollection";
      flake = false;
    };

    deploy-rs = {
      type = "github";
      owner = "serokell";
      repo = "deploy-rs";
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
                      "${toString ./home}/${unixName}/configurations/${hostName}"
                    ]
                    ++ (with outputs.homeManagerModules; [
                      default
                      extra
                    ])
                    ++ [
                      outputs.homeManagerModules."${unixName}"
                    ];
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
            homeConfigurations =
              nixpkgs.lib.foldr (a: b: a // b) { } (
                map (hostName: mkHomeConfig { inherit hostName; }) [
                  "Tytonidae"
                  "Akun"
                ]
              )
              // mkHomeConfig {
                hostName = "Cape";
                unixName = "alice";
              };
            homeManagerModules =
              {
                default = import ./home/modules;
                extra = import ./home/extra;
              }
              // (
                let
                  allEntries = builtins.readDir ./home;
                  allUsers = nixpkgs.lib.filterAttrs (
                    key: value:
                    value == "directory"
                    && (
                      !builtins.elem key [
                        "modules"
                        "extra"
                      ]
                    )
                  ) allEntries;
                in
                builtins.listToAttrs (
                  map (name: {
                    name = name;
                    value = import "${toString ./home}/${name}/modules";
                  }) (builtins.attrNames allUsers)
                )
              );
          }
        )
        // (
          let
            mkDeployNode =
              {
                hostName,
                unixName ? "deploy",
                system ? "x86_64-linux",
                sshName ? hostName,
              }:
              {
                "${hostName}" = {
                  hostname = "${sshName}";
                  sshUser = "${unixName}";
                  interactiveSudo = true;
                  profiles = {
                    system = {
                      user = "${unixName}";
                      path =
                        inputs.deploy-rs.lib."${system}".activate.nixos
                          self.outputs.nixosConfigurations."${hostName}";
                    };
                  };
                };
              };
          in
          {
            deploy.nodes = nixpkgs.lib.foldr (a: b: a // b) { } (
              map
                (
                  hostName:
                  mkDeployNode {
                    inherit hostName;
                  }
                )
                [
                  "Cape"
                ]
            );
          }
        );
    };
}
