{
  # Account deploy-rs logs in as; core/deploy.nix includes it on hosts
  # with deploy.enable.
  den.aspects.deploy.nixos.users.users.deploy = {
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
}
