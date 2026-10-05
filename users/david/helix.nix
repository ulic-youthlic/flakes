{ den, ... }:
{
  # david's taste on top of the shared helix setup.
  den.aspects.david.helix = {
    includes = [ den.aspects.helix ];
    homeManager =
      { pkgs, ... }:
      {
        catppuccin.helix.enable = false;
        programs.helix.settings = {
          theme = "papercolor-light";
        };
        programs.helix.extraPackages = with pkgs; [ editor-runtime ];
      };
  };
}
