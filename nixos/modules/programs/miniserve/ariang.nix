{
  pkgs,
  lib,
  ...
}:
{
  config.youthlic.programs.miniserve.templates.ariang =
    { port, ... }@args:
    {
      inherit port;
      directory = args.ariang or "${pkgs.ariang}/share/ariang";
      defaultIndex = "index.html";
      isSpa = true;
    }
    // (lib.optionalAttrs (args ? interface) {
      inherit (args) interface;
    });
}
