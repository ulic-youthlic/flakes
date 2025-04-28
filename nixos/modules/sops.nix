{
  rootPath,
  config,
  ...
}: {
  config = {
    sops.defaultSopsFile = rootPath + "/secrets/general.yaml";
    sops.age = {
      keyFile = "/var/sops/key.txt";
      sshKeyPaths = [];
      generateKey = false;
    };
  };
}
