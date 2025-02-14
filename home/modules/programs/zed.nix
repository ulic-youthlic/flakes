{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.youthlic.programs.zed-editor;
in
{
  options = {
    youthlic.programs.zed-editor = {
      enable = lib.mkEnableOption "zed-editor";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "nix"
      ];
      extraPackages = with pkgs; [
        nixd
        nil
      ];
      userSettings = {
        vim_mode = true;
      };
    };
  };
}
