{
  config,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.radicle;
in {
  options = {
    youthlic.programs.radicle = {
      enable = lib.mkEnableOption "radicle";
      privateKeyFile = lib.mkOption {
        type = with lib.types; either path str;
      };
      publicKey = lib.mkOption {
        type = with lib.types; either path str;
      };
      domain = lib.mkOption {
        type = lib.types.str;
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.radicle = {
        enable = true;
        inherit (cfg) publicKey privateKeyFile;
        node.openFirewall = true;
        httpd = {
          enable = true;
          listenPort = 8489;
        };
        settings = {
          publicExplorer = "https://app.radicle.xyz/nodes/$host/$rid$path";
          preferredSeeds = [
            "z6Mkmqogy2qEM2ummccUthFEaaHvyYmYBYh3dbe9W4ebScxo@ash.radicle.garden:8776"
            "z6MksmpU5b1dS7oaqF2bHXhQi1DWy2hB7Mh9CuN7y1DN6QSz@seed.radicle.xyz:8776"
            "z6MkrLMMsiPWUcNPHcRajuMi9mDfYckSoJyPwwnknocNYPm7@seed.radicle.garden:8776"
          ];
          web = {
            bannerUrl = "https://radicle.${config.youthlic.programs.caddy.baseDomain}/images/youthlic-seed-header.png";
            avatarUrl = "https://radicle.${config.youthlic.programs.caddy.baseDomain}/images/youthlic-seed-avatar.jpg";
            description = "Private Seed Server.";
            pinned = {
              repositories = [
                "rad:z3gqcJUoA1n9HaHKufZs5FCSGazv5"
                "rad:z4D5UCArafTzTQpDZNQRuqswh3ury"
                "rad:z4V1sjrXqjvFdnCUbxPFqd5p4DtH5"
                "rad:z6cFWeWpnZNHh9rUW8phgA3b5yGt"
              ];
            };
          };
          cli = {
            hints = true;
          };
          node = {
            alias = cfg.domain;
            listen = [];
            peers = {
              type = "dynamic";
            };
            connect = [];
            externalAddresses = [
              "${cfg.domain}:8776"
            ];
            network = "main";
            log = "INFO";
            relay = "auto";
            limits = {
              routingMaxSize = 1000;
              routingMaxAge = 604800;
              gossipMaxAge = 1209600;
              fetchConcurrency = 1;
              maxOpenFiles = 4096;
              rate = {
                inbound = {
                  fillRate = 5.0;
                  capacity = 1024;
                };
                outbound = {
                  fillRate = 10.0;
                  capacity = 2048;
                };
              };
              connection = {
                inbound = 128;
                outbound = 16;
              };
            };
            workers = 8;
            seedingPolicy = {
              default = "block";
            };
          };
        };
      };
    })
    (lib.mkIf (cfg.enable && config.youthlic.programs.caddy.enable) {
      services.caddy.virtualHosts = {
        "${cfg.domain}" = {
          extraConfig = ''
            reverse_proxy 127.0.0.1:8489
          '';
        };
      };
    })
  ];
}
