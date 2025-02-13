{ lib, config, ... }:
let
  cfg = config.youthlic.programs.transfer-sh;
in
{
  options = {
    youthlic.programs.transfer-sh = {
      enable = lib.mkEnableOption "transfer.sh";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.transfer-sh = {
        enable = true;
        provider = "local";
        settings = {
          BASEDIR = "/var/lib/transfer.sh";
          LISTENER = ":8484";
          TLS_LISTENER_ONLY = false;
        };
      };
    })
    (lib.mkIf (cfg.enable && config.youthlic.programs.caddy.enable) {
      services.caddy.virtualHosts = {
        "transfer.${config.youthlic.programs.caddy.baseDomain}" = {
          extraConfig = ''
            reverse_proxy 127.0.0.1:8484
          '';
        };
      };
    })
  ];
}
