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
  };
  outputs = {
    self,
    flake-utils,
    nixpkgs,
    rust-overlay,
    advisory-db,
    crane,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      inherit (pkgs) lib;
      pkgs = import nixpkgs {
        inherit system;
        overlays = [(import rust-overlay)];
      };
      rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;
      srcFilters = path: type:
        builtins.any (suffix: lib.hasSuffix suffix path) [
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
      nativeBuildInputs = with pkgs; [];
      buildInputs =
        (with pkgs; [])
        ++ lib.optional pkgs.stdenv.buildPlatform.isDarwin (with pkgs; [
          darwin.apple_sdk.frameworks.Security
        ]);
      cargoArtifacts = craneLib.buildDepsOnly (basicArgs
        // {
          inherit buildInputs nativeBuildInputs;
        });
      commonArgs =
        basicArgs
        // {
          inherit cargoArtifacts buildInputs nativeBuildInputs;
        };
    in {
      formatter = pkgs.alejandra;
      checks = {
        package = self.packages.${system}.default.overrideAttrs {
          doCheck = true;
        };
        clippy = craneLib.cargoClippy (commonArgs
          // {
            cargoClippyExtraArgs = "--all-targets -- --deny warnings";
          });
        doc = craneLib.cargoDoc commonArgs;
        deny = craneLib.cargoDeny commonArgs;
        fmt = craneLib.cargoFmt basicArgs;
        audit = craneLib.cargoAudit {
          inherit src advisory-db;
        };
        nextest = craneLib.cargoNextest (commonArgs
          // {
            partitions = 1;
            partitionType = "count";
            cargoNextestExtraArgs = "--no-tests pass";
            env = {
              CARGO_PROFILE = "dev";
            };
          });
      };
      packages = rec {
        rust-demo = craneLib.buildPackage (commonArgs
          // {
            inherit
              (craneLib.crateNameFromCargoToml {
                cargoToml = "${toString src}/Cargo.toml";
              })
              pname
              version
              ;
            doCheck = false;
          });
        default = rust-demo;
      };
      apps.default = flake-utils.lib.mkApp {
        drv = self.packages."${system}".default;
      };
      devShells.default = craneLib.devShell {
        checks = self.checks.${system};
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
    });
  nixConfig = {
    keepOutputs = true;
  };
}
