{
  config,
  lib,
  ...
}:
let
  cfg = config.youthlic.programs.aria2;
in
{
  options = {
    youthlic.programs.aria2 = {
      enable = lib.mkEnableOption "aria2";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.aria2 = {
      enable = true;
      systemd.enable = true;
      settings = {
        dir = toString config.xdg.userDirs.download;
        log = "-";
        max-concurrent-downloads = 5;
        check-integrity = true;
        continue = true;
        all-proxy = "http://127.0.0.1:7799";
        max-connection-per-server = 5;
        min-split-size = "20M";
        split = 5;
        rpc-listen-port = 6800;
      };
    };
  };
}
