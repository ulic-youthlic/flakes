{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.tailscale;
in {
  options = {
    youthlic.programs.tailscale = {
      enable = lib.mkEnableOption "tailscale";
    };
  };
  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      openFirewall = true;
    };
  };
}
