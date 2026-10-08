{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "nixos-shell";
        packages = with pkgs; [
          nixd
          nil
          typos
          typos-lsp
          just
          nvfetcher
          alejandra
          oxfmt

          # for go modules
          go
          gomod2nix
        ];
      };
    };
}
