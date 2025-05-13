{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.jujutsu;
in {
  options = {
    youthlic.programs.jujutsu = {
      enable = lib.mkEnableOption "jujutsu";
      email = lib.mkOption {
        type = lib.types.str;
        description = ''
          jujutsu email
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
      name = lib.mkOption {
        type = lib.types.str;
        example = ''youthlic'';
        description = ''
          jujutsu name
        '';
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        delta
        watchman
      ];
      programs.jujutsu = {
        enable = true;
        settings = {
          "$schema" = "https://jj-vcs.github.io/jj/latest/config-schema.json";
          snapshot = {
            auto-track = "true";
            max-new-file-size = 0;
          };
          core = {
            fsmonitor = "watchman";
            watchman.register-snapshot-trigger = true;
          };
          user = {
            name = cfg.name;
            email = cfg.email;
          };
          ui = {
            color = "auto";
            movement.edit = true;
            graph.style = "curved";
            show-cryptographic-signatures = true;
            pager = "delta";
            diff = {
              color-words = {
                conflict = "pair";
              };
            };
            default-command = "log";
          };
          templates = {
            log = ''
              builtin_log_compact_full_description
            '';
          };
          template-aliases = {
            "format_short_signature(signature)" = "signature";
          };
          revset-aliases = {
            "immutable_heads()" = ''
              builtin_immutable_heads() | (trunk().. & ~mine())
            '';
          };
          git = {
            abandon-unreachable-commits = false;
          };
        };
      };
    })
    (lib.mkIf (cfg.enable && (cfg.signKey != null)) {
      programs.jujutsu.settings = {
        git = {
          sign-on-push = true;
        };
        signing = {
          behavior = "drop";
          backend = "gpg";
          key = cfg.signKey;
        };
      };
    })
  ];
}
