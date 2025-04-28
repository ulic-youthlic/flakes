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
        "nix"
        "html"
        "java"
        "git-firely"
        "make"
        "deno"
        "java-eclipse-jdtlS"
        "neocMake"
        "typst"
        "toml"
        "markdown-oxide"
      ];
      extraPackages = with pkgs; [
        nixd
        nil
        neocmakelsp
        deno
        jdt-language-server
        taplo
        alejandra
        markdown-oxide
      ];
      userSettings = {
        soft_wrap = "editor_width";
        autosave = "on_focus_change";
        auto_update = false;
        calls = {
          mute_on_join = true;
          share_on_join = false;
        };
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
