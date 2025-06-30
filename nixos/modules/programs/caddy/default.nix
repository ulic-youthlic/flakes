{
  lib,
  config,
  ...
}: let
  cfg = config.youthlic.programs.caddy;
in {
  imports = [
    ./radicle-explorer.nix
    ./OuterWildsTextAdventure.nix
  ];
  options = {
    youthlic.programs.caddy = {
      enable = lib.mkEnableOption "caddy";
      baseDomain = lib.mkOption {
        type = lib.types.str;
        example = "youthlic.social";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
    };
    networking.firewall = {
      allowedTCPPorts = [443];
    };
  };
}
