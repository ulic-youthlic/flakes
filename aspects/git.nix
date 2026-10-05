{ den, lib, ... }:
{
  den.aspects.git =
    { user, ... }:
    let
      identity = user.identity;
      signingKey = identity.signingKey or null;
      credential = user.git.sops or null;
    in
    {
      includes = lib.optional (signingKey != null) den.aspects.gpg;
      homeManager = {
        config = lib.mkMerge [
          {
            programs = {
              gh = {
                enable = true;
                gitCredentialHelper.enable = true;
                settings = {
                  git_protocol = "ssh";
                };
              };
              git = {
                enable = true;
                settings = {
                  alias.patch = "push rad HEAD:refs/patches";
                  user = { inherit (identity) name email; };
                };
                lfs.enable = true;
              };
              delta = {
                enable = true;
                options = {
                  line-number = true;
                  hyperlinks = true;
                  side-by-side = true;
                };
              };
            };
          }
          (lib.mkIf (signingKey != null) {
            programs.git.signing = {
              signByDefault = true;
              key = signingKey;
              format = "openpgp";
            };
          })
          (lib.mkIf (credential != null) {
            sops.secrets.${credential.secret} = {
              inherit (credential) path;
              mode = "0640";
            };
            programs.git.settings = {
              credential.helper = "store --file=${credential.path}";
              core.commentChar = ";";
            };
          })
        ];
      };
    };
}
