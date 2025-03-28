{
  description = "A simple NixOS flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "github:NixOS/nixpkgs/master";
    # nixpkgs.follows = "nixos-cosmic/nixpkgs";

    nixpkgs-d056063028f6cbe9b99c3a4b52fdad99573db3ab = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "d056063028f6cbe9b99c3a4b52fdad99573db3ab";
    };

    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
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
        flake-utils.follows = "flake-utils";
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

    oskars-dotfiles = {
      type = "github";
      owner = "oskardotglobal";
      repo = ".dotfiles";
      ref = "nix";
      flake = false;
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

    ghostty = {
      type = "github";
      owner = "ghostty-org";
      repo = "ghostty";
      inputs = {
        nixpkgs-unstable.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
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
        flake-utils.follows = "flake-utils";
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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
    };

    jj = {
      type = "github";
      owner = "jj-vcs";
      repo = "jj";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
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
      imports = [
        inputs.home-manager.flakeModules.home-manager
      ];
      perSystem =
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
        };
      flake =
        {
          nix.settings = {
            # substituters shared in home-manager and nixos configuration
            substituters =
              let
                cachix = x: "https://${x}.cachix.org";
              in
              nixpkgs.lib.flatten [
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
              makeNixConfiguration =
                hostName:
                nixpkgs.lib.nixosSystem {
                  modules =
                    [ outputs.nixosModules.default ]
                    ++ [
                      (
                        let
                          dirPath = nixosConfigDir + "/${hostName}";
                          filePath = nixosConfigDir + "/${hostName}.nix";
                        in
                        if builtins.pathExists dirPath then dirPath else filePath
                      )
                    ];
                  specialArgs = { inherit inputs outputs rootPath; };
                };
            in
            nixosConfigDir
            |> builtins.readDir
            |> builtins.attrNames
            |> map (f: nixpkgs.lib.removeSuffix ".nix" f)
            |> map (name: {
              inherit name;
              value = makeNixConfiguration name;
            })
            |> builtins.listToAttrs;
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
                    ++ (with outputs.homeModules; [
                      default
                      extra
                    ])
                    ++ [
                      outputs.homeModules."${unixName}"
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
            homeModules =
              {
                default = import ./home/modules;
                extra = import ./home/extra;
              }
              // (
                ./home
                |> builtins.readDir
                |> nixpkgs.lib.filterAttrs (key: value: value == "directory")
                |> nixpkgs.lib.filterAttrs (
                  key: value:
                  !builtins.elem key [
                    "modules"
                    "extra"
                  ]
                )
                |> builtins.attrNames
                |> map (name: {
                  name = name;
                  value = import "${toString ./home}/${name}/modules";
                })
                |> builtins.listToAttrs
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
                      user = "root";
                      path =
                        inputs.deploy-rs.lib."${system}".activate.nixos
                          self.outputs.nixosConfigurations."${hostName}";
                    };
                  };
                };
              };
          in
          {
            deploy.nodes =
              [
                "Cape"
                "Akun"
              ]
              |> map (
                hostName:
                mkDeployNode {
                  inherit hostName;
                }
              )
              |> nixpkgs.lib.foldr (a: b: a // b) { };
          }
        );
    };
}
