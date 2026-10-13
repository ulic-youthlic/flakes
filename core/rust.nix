{
  perSystem = { config, pkgs, ... }: {
    devShells.rust = pkgs.mkShell {
      name = "rust-shell";
      inputsFrom = [ config.devShells.default ];

      packages = builtins.attrValues {
        inherit (pkgs)
          cargo
          clippy
          rust-analyzer
          rustc
          rustfmt
          ;
      };
    };
  };
}
