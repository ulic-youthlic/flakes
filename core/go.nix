{
  perSystem = { config, pkgs, ... }: {
    devShells.go = pkgs.mkShell {
      name = "go-shell";
      inputsFrom = [ config.devShells.default ];

      packages = builtins.attrValues {
        inherit (pkgs)
          go
          gomod2nix
          gotools
          gofumpt
          gopls
          golangci-lint-langserver
          delve
          golangci-lint
          govulncheck
          gotestsum
          ;
      };
    };
  };
}
