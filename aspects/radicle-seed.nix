{ den, ... }:
{
  den.aspects.radicle-seed = {
    # The seed's web banner and avatar are served by the explorer site.
    includes = [ den.aspects.caddy.radicle-explorer ];
    nixos =
      {
        lib,
        host,
        ...
      }:
      let
        cfg = host.radicle-seed;
      in
      {
        config = lib.mkMerge [
          {
            sops.secrets.${cfg.sops.secret}.path = cfg.sops.path;
            services.radicle = {
              enable = true;
              inherit (cfg) publicKey;
              privateKey = cfg.sops.path;
              node.openFirewall = true;
              httpd = {
                enable = true;
                listenPort = 8489;
              };
              settings = {
                publicExplorer = "https://radicle.network/nodes/$host/$rid$path";
                preferredSeeds = [
                  "z6Mkmqogy2qEM2ummccUthFEaaHvyYmYBYh3dbe9W4ebScxo@rosa.radicle.network:58776"
                  "z6MksmpU5b1dS7oaqF2bHXhQi1DWy2hB7Mh9CuN7y1DN6QSz@seed.radicle.dev:58776"
                  "z6MkrLMMsiPWUcNPHcRajuMi9mDfYckSoJyPwwnknocNYPm7@iris.radicle.network:58776"
                ];
                web = {
                  bannerUrl = "https://radicle.${host.caddy.baseDomain}/images/youthlic-seed-header.png";
                  avatarUrl = "https://radicle.${host.caddy.baseDomain}/images/youthlic-seed-avatar.jpg";
                  description = "Private Seed Server.";
                  pinned = {
                    repositories = [
                      "rad:z3gqcJUoA1n9HaHKufZs5FCSGazv5"
                      "rad:z4D5UCArafTzTQpDZNQRuqswh3ury"
                      "rad:z4V1sjrXqjvFdnCUbxPFqd5p4DtH5"
                      "rad:z6cFWeWpnZNHh9rUW8phgA3b5yGt"
                      "rad:z4Uh671FzoooaHjLvmtW9BtGMF9qm"
                    ];
                  };
                };
                cli = {
                  hints = true;
                };
                node = {
                  alias = cfg.domain;
                  listen = [ ];
                  peers = {
                    type = "dynamic";
                  };
                  connect = [ ];
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
          }
          (lib.mkIf (host.caddy.enable or false) {
            services.caddy.virtualHosts = {
              "${cfg.domain}" = {
                extraConfig = ''
                  reverse_proxy 127.0.0.1:8489
                '';
              };
            };
          })
        ];
      };
  };
}
