{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      formatter = pkgs.alejandra;
      checks = {
        inherit (self.packages.${system}) default;
      };
      devShells.default = pkgs.mkShell {
        inputsFrom = [] ++ (builtins.attrValues self.checks.${system});
        packages = with pkgs; [
          clang-tools
        ];
      };
      packages = rec {
        cxx-demo = pkgs.stdenv.mkDerivation {
          pname = "cxx-demo";
          version = "unstable";
          src = ./.;
          strictDeps = true;
          nativeBuildInputs = with pkgs; [
            xmake
            gnumake
          ];
          preConfigure = ''
            xmake config -m release
            xmake project -k xmakefile
          '';
          env = {
            INSTALLDIR = "${placeholder "out"}";
            NIX_DEBUG = 1;
            V = 1;
            D = 1;
          };
        };
        default = cxx-demo;
      };
    });
  nixConfig = {
    keepOutputs = true;
  };
}
