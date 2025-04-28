{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.youthlic.programs.rustypaste-cli;
in {
  options = {
    youthlic.programs.rustypaste-cli = {
      enable = lib.mkEnableOption "rustypaste-cli";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.rustypaste-cli];
    sops = {
      secrets = {
        "rustypaste/auth" = {};
        "rustypaste/delete" = {};
      };
      templates."rustypaste-config.toml" = {
        path = "${config.xdg.configHome}/rustypaste/config.toml";
        content = ''
          [server]
          address = "https://paste.youthlic.fun"
          auth_token = "${config.sops.placeholder."rustypaste/auth"}"
          delete_token = "${config.sops.placeholder."rustypaste/delete"}"

          [paste]
          oneshot = false

          [style]
          prettify = true
        '';
      };
    };
  };
}
