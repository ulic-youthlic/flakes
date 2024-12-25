{
  lib,
  pkgs,
  config,
  ...
}:
{
  options = {
    youthlic.programs.helix = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = ''
          enable helix editor
        '';
      };
      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          taplo
          markdown-oxide
          nixd
          deno
          nixfmt-rfc-style
        ];
        example = (
          with pkgs;
          [
            deno
          ]
        );
        description = ''
          extra packages for helix lsp and formatter
        '';
      };
    };
  };
  config =
    let
      cfg = config.youthlic.programs.helix;
    in
    {
      programs.helix = lib.mkIf cfg.enable {
        enable = true;
        defaultEditor = true;
        settings =
          let
            config-file = builtins.readFile ./config.toml;
            config = builtins.fromTOML config-file;
          in
          config;
      };
      home.packages = cfg.extraPackages;
    };
}
