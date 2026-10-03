{
  den.aspects.david.thunderbird.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = {
        programs.thunderbird = {
          enable = true;
          package = pkgs.thunderbird-bin;
          profiles = {
            default = {
              withExternalGnupg = true;
              isDefault = true;
            };
          };
        };
      };
    };
}
