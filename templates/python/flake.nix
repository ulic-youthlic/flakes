{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  outputs =
    {
      flake-utils,
      nixpkgs,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        inherit (pkgs) lib;
        pkgs = import nixpkgs {
          inherit system;
          config = {
            cudaSupport = true;
            allowUnfree = true;
          };
        };
        defaultPython = pkgs.python3;
      in
      {
        formatter = pkgs.alejandra;
        devShells.default = pkgs.mkShell {
          packages =
            (with pkgs; [
              ruff
              pyright

              uv
              defaultPython
            ])
            ++ (with pkgs.python3Packages; [
              pydantic
              torchWithCuda
            ]);
          shellHook = ''
            uv sync
            . ./.venv/bin/activate
          '';
          env = {
            UV_PYTHON_DOWNLOADS = "never";
            UV_PYTHON = "${lib.getExe' defaultPython "python"}";
            UV_TORCH_BACKEND = "auto";
          };
        };
      }
    );
  nixConfig = {
    keepOutputs = true;
  };
}
