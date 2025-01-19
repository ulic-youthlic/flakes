{
  config,
  lib,
  ...
}:
{
  options = {
    youthlic.programs.git = {
      email = lib.mkOption {
        type = lib.types.str;
        description = ''
          git email
        '';
      };
      name = lib.mkOption {
        type = lib.types.str;
        example = ''youthlic'';
        description = ''
          git name
        '';
      };
      signKey = lib.mkOption {
        type = lib.types.addCheck (lib.types.nullOr lib.types.str) (
          x: (x == null || config.youthlic.programs.gpg.enable)
        );
        default = null;
        description = ''
          key fingerprint for sign commit
        '';
      };
      encrypt-credential = lib.mkEnableOption "encrypt git credential";
    };
  };
  config =
    let
      cfg = config.youthlic.programs.git;
    in
    {
      programs.lazygit = {
        enable = true;
      };
      programs.gh = {
        enable = true;
        gitCredentialHelper.enable = true;
        settings = {
          git_protocol = "ssh";
        };
      };
      sops.secrets."git-credential" = {
        mode = "0640";
      };
      programs.git = lib.mkMerge [
        {
          enable = true;
          userEmail = cfg.email;
          userName = cfg.name;
          delta = {
            enable = true;
            options = {
              line-number = true;
              hyperlinks = true;
              side-by-side = true;
            };
          };
          lfs.enable = true;
        }
        (lib.mkIf cfg.encrypt-credential {
          extraConfig = {
            credential = {
              helper = "store --file=${config.sops.secrets."git-credential".path}";
            };
          };
        })
        (lib.mkIf (cfg.signKey != null) {
          signing = {
            signByDefault = true;
            key = cfg.signKey;
          };
        })
      ];
    };
}
