{
  den.aspects.documentation.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = lib.mkIf config.documentation.enable (
        builtins.attrValues {
          inherit (pkgs)
            man-pages
            man-pages-posix
            ;
        }
      );
      documentation = {
        # Defaults, so a host can drop them: they pull perl in through
        # texinfo and nixos-help's w3m.
        info.enable = lib.mkDefault true;
        nixos.enable = lib.mkDefault true;
        dev.enable = true;
        man = {
          enable = true;
          cache = {
            enable = true;
            generateAtRuntime = true;
          };
        };
      };
    };
}
