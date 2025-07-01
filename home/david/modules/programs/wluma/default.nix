{
  lib,
  config,
  ...
}: let
  cfg = config.david.programs.wluma;
in {
  options = {
    david.programs.wluma = {
      enable = lib.mkEnableOption "wluma";
    };
  };
  config = lib.mkIf cfg.enable {
    services.wluma = {
      enable = true;
      settings = ./config.toml |> builtins.readFile |> builtins.fromTOML;
      systemd = {
        enable = true;
      };
    };
  };
}
