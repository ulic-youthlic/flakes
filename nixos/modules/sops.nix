{
  rootPath,
  config,
  ...
}:
{
  config = {
    sops.defaultSopsFile = rootPath + "/secrets/general.yaml";
    sops.age =
      let
        unixName = config.youthlic.home-manager.unixName;
        cfg = config.users.users."${unixName}";
      in
      {
        keyFile = "${cfg.home}/.config/sops/age/keys.txt";
        sshKeyPaths = [ ];
        generateKey = false;
      };
  };
}
