{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "nixos-shell";
        packages = with pkgs; [
          deploy-rs
          nixd
          nil
          typos
          typos-lsp
          just
          nvfetcher
          alejandra
          oxfmt
        ];
      };
    };
}
