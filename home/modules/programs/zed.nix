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
    stylix.targets.zed.enable = false;
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
        autosave = "on_focus_change";
        auto_update = false;
        "format_on_save" = "off";
        ui_font_size = 20;
        buffer_font_size = 20;
        buffer_font_family = "Maple Mono NF CN";
        buffer_font_features = {
          "calt" = true;
          "zero" = true;
          "cv03" = true;
          "cv96" = true;
          "cv97" = true;
          "cv98" = true;
          "ss08" = true;
        };
        ui_font_family = "Source Han Sans SC";
        theme = "Ayu Dark";
        vim_mode = true;
      };
    };
  };
}
