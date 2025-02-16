{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  rootPath,
  ...
}:
{
  options.youthlic.home-manager = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        whether enable home-manager or not
      '';
    };
    unixName = lib.mkOption {
      type = lib.types.str;
      default = "david";
      example = "youthlic";
      description = ''
        unix name of home-manager user
      '';
    };
    hostName = lib.mkOption {
      type = lib.types.str;
      example = "Tytonidae";
      description = ''
        host name of home-manager user
      '';
    };
  };
  config =
    let
      cfg = config.youthlic.home-manager;
      unixName = cfg.unixName;
      hostName = cfg.hostName;
    in
    lib.mkIf cfg.enable {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users."${cfg.unixName}" = (
          { ... }:
          {
            imports = [
              outputs.homeManagerModules."${unixName}"
              (rootPath + "/home/${unixName}/configurations/${hostName}")
            ];
          }
        );
        extraSpecialArgs = {
          inherit outputs inputs rootPath;
          inherit (cfg) unixName hostName;
          inherit (pkgs) system;
        };
        backupFileExtension = "backup";
        sharedModules = [ outputs.homeManagerModules.default ];
      };
    };
}
