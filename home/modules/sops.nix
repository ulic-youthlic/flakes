{
  lib,
  config,
  pkgs,
  rootPath,
  ...
}:
{
  options = {
    youthlic.programs.sops = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = ''
          whether enable sops-nix or not
        '';
      };
      keyFile = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        description = ''
          path to age key file
        '';
      };
    };
  };
  config =
    let
      cfg = config.youthlic.programs.sops;
    in
    lib.mkIf cfg.enable {
      home.packages = (
        with pkgs;
        [
          sops
          age
        ]
      );
      sops = {
        age = {
          keyFile = cfg.keyFile;
          generateKey = false;
        };
        defaultSopsFile = rootPath + "/secrets/general.yaml";
      };
    };
}
