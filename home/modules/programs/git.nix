{
  config,
  lib,
  ...
}: {
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
  config = let
    cfg = config.youthlic.programs.git;
  in
    lib.mkMerge [
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
            settings.user = {
              inherit (cfg) email name;
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
      (lib.mkIf (cfg.signKey != null) {
        programs.git.signing = {
          signByDefault = true;
          key = cfg.signKey;
          format = "openpgp";
        };
      })
      (lib.mkIf cfg.encrypt-credential {
        programs.git.settings = {
          credential = {
            helper = "store --file=${config.sops.secrets."git-credential".path}";
          };
          core = {
            commentChar = ";";
          };
        };
        sops.secrets."git-credential" = {
          mode = "0640";
        };
      })
    ];
}
