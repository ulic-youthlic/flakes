{
  perSystem = { config, pkgs, ... }: {
    devShells.bash = pkgs.mkShell {
      name = "bash-shell";
      inputsFrom = [ config.devShells.default ];

      packages = builtins.attrValues {
        inherit (pkgs)
          bashInteractive
          bash-language-server
          shellcheck
          shfmt
          ;
      };
    };
  };
}
