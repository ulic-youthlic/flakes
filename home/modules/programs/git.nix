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
        programs.git = {
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
        programs.git.extraConfig = {
          credential = {
            helper = "store --file=${config.sops.secrets."git-credential".path}";
          };
        };
        sops.secrets."git-credential" = {
          mode = "0640";
        };
      })
    ];
}
