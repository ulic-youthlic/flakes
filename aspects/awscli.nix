{
  den.aspects.awscli.homeManager =
    {
      lib,
      pkgs,
      user,
      ...
    }:
    let
      cfg = user.awscli;
    in
    {
      sops.secrets.${cfg.sops.secret}.path = cfg.sops.path;
      programs.awscli = {
        enable = true;
        credentials = {
          default = {
            credential_process = "${lib.getExe' pkgs.uutils-coreutils-noprefix "cat"} ${cfg.sops.path}";
          };
        };
        settings = {
          default = {
            region = "garage";
            endpoint_url = cfg.endpoint;
          };
        };
      };
    };
}
