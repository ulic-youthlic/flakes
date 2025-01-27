{ config, lib, ... }:
let
  cfg = config.youthlic.users.deploy;
in
{
  options = {
    youthlic.users.deploy = {
      enable = lib.mkEnableOption "deploy";
    };
  };
  config = lib.mkIf cfg.enable {
    users.users.deploy = {
      isNormalUser = true;
      hashedPassword = "$y$j9T$B/igbpUxYMx9W4hV/Uc0/.$Z9.cTGfXQ0YD03MmfvDCd6.ijEo5L9v2CbrhN8Fvkf6";
      home = "/home/deploy";
      extraGroups = [
        "wheel"
        "nix"
      ];
      openssh.authorizedKeys.keyFiles = [
        ./id_ed25519_deploy.pub
      ];
    };
  };
}
