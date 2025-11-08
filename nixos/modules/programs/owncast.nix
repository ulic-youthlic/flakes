{
  lib,
  config,
  ...
}: let
  cfg = config.youthlic.programs.owncast;
in {
  options = {
    youthlic.programs.owncast = {
      enable = lib.mkEnableOption "owncast";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.owncast = {
        enable = true;
        listen = "0.0.0.0";
        port = 8486;
        rtmp-port = 1935;
        openFirewall = true;
      };
    })
    (lib.mkIf (cfg.enable && config.youthlic.programs.caddy.enable) {
      services.caddy.virtualHosts = {
        "owncast.${config.youthlic.programs.caddy.baseDomain}" = {
          extraConfig = ''
            reverse_proxy 127.0.0.1:8486
          '';
        };
      };
    })
  ];
}
