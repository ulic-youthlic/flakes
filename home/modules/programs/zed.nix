{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.zed-editor;
in {
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
        "Nix"
        "HTML"
        "Java"
        "Git Firely"
        "Make"
        "Deno"
        "Java with Eclipse JDTLS"
        "NeoCMake"
        "Typst"
      ];
      extraPackages = with pkgs; [
        nixd
        nil
        neocmakelsp
        deno
        jdt-language-server
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
          "ss08" = true;
        };
        ui_font_family = "Source Han Sans SC";
        theme = "Gruvbox Dark Hard";
        vim_mode = true;
        vim = {
          default_mode = "helix_normal";
        };
      };
    };
  };
}
