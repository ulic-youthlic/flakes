{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
    crane = {
      url = "github:ipetkov/crane";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };
  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      rust-overlay,
      advisory-db,
      crane,
      pre-commit-hooks,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        inherit (pkgs) lib;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import rust-overlay)
            (_final: prev: {
              lib = prev.lib // (import ./nix/lib.nix prev.lib);
            })
          ];
        };
        rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;
        srcFilters =
          path: type:
          builtins.any (lib.flip lib.hasSuffix path) [
            ".sql"
            ".diff"
            ".md"
            ".adoc"
            ".json"
          ]
          || (craneLib.filterCargoSources path type);
        src = lib.cleanSourceWith {
          src = ./.;
          filter = srcFilters;
        };
        basicArgs = {
          inherit src;
          strictDeps = true;
        };
        nativeBuildInputs = [ ];
        buildInputs = [ ];
        genInputs = lib.genInputsWith pkgs;
        commonArgs = basicArgs // {
          cargoArtifacts = self.packages.${system}.cargo-artifacts;
          buildInputs = genInputs buildInputs;
          nativeBuildInputs = genInputs nativeBuildInputs;
        };
      in
      {
        formatter = pkgs.alejandra;
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              alejandra = {
                enable = true;
              };
              rustfmt.enable = true;
              cargo-check = {
                enable = true;
                stages = [ "pre-push" ];
              };
              clippy = {
                enable = true;
                stages = [ "pre-push" ];
                settings.denyWarnings = true;
              };
            };
          };
          package = self.packages.${system}.default.overrideAttrs {
            doCheck = true;
          };
          clippy = craneLib.cargoClippy (
            commonArgs
            // {
              cargoClippyExtraArgs = "--all-targets -- --deny warnings";
            }
          );
          doc = craneLib.cargoDoc commonArgs;
          deny = craneLib.cargoDeny commonArgs;
          fmt = craneLib.cargoFmt basicArgs;
          audit = craneLib.cargoAudit {
            inherit src advisory-db;
          };
          nextest = craneLib.cargoNextest (
            commonArgs
            // {
              partitions = 1;
              partitionType = "count";
              cargoNextestExtraArgs = "--no-tests pass";
              env = {
                CARGO_PROFILE = "dev";
              };
            }
          );
        };
        packages =
          let
            callPackage = lib.callPackageWith (pkgs // { inherit craneLib callPackage; });
            packageArgs = {
              inherit
                lib
                basicArgs
                buildInputs
                nativeBuildInputs
                ;
            };
            importWithArgs = with lib; flip import packageArgs;
          in
          rec {
            cargo-artifacts = callPackage (importWithArgs ./nix/cargo-artifacts.nix) { };
            rust-demo = callPackage (importWithArgs ./nix/package.nix) {
              cargoArtifacts = cargo-artifacts;
            };
            default = rust-demo;
          };
        apps.default = flake-utils.lib.mkApp {
          drv = self.packages."${system}".default;
        };
        devShells.default = craneLib.devShell {
          checks = self.checks.${system};
          shellHook = '''' + self.checks.${system}.pre-commit-check.shellHook;
          packages = with pkgs; [
            rust-analyzer
            cargo-audit
            cargo-deny
            cargo-watch
            cargo-nextest
          ];
          env = {
            RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          };
        };
      }
    );
  nixConfig = {
    keepOutputs = true;
  };
}
