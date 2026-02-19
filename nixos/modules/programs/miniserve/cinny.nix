{
  pkgs,
  lib,
  ...
}: {
  config.youthlic.programs.miniserve.templates.cinny = {port, ...} @ args:
    {
      inherit port;
      directory = args.cinny or (toString pkgs.cinny);
      defaultIndex = "index.html";
      isSpa = true;
    }
    // (lib.optionalAttrs (args ? interface) {
      inherit (args) interface;
    });
}
