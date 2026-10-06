{ den, lib, ... }:
let
  settings = {
    publicExplorer = "https://radicle.network/nodes/$host/$rid$path";
    preferredSeeds = [
      "z6Mkmqogy2qEM2ummccUthFEaaHvyYmYBYh3dbe9W4ebScxo@rosa.radicle.network:58776"
      "z6MksmpU5b1dS7oaqF2bHXhQi1DWy2hB7Mh9CuN7y1DN6QSz@seed.radicle.dev:58776"
      "z6MkrLMMsiPWUcNPHcRajuMi9mDfYckSoJyPwwnknocNYPm7@iris.radicle.network:58776"
    ];
    cli.hints = true;
    node = {
      peers.type = "dynamic";
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
          inbound.capacity = 1024;
          outbound.capacity = 2048;
        };
        connection = {
          inbound = 128;
          outbound = 16;
        };
      };
      workers = 8;
      seedingPolicy.default = "block";
    };
  };
in
{
  den.aspects = {
    radicle =
      { user, ... }:
      let
        cfg = user.radicle or { };
        credential = cfg.sops or null;
      in
      {
        includes = lib.optionals (credential != null) [
          den.aspects.sops
          {
            homeManager = {
              sops.secrets.${credential.secret}.path = credential.path;
              systemd.user.services.radicle-node.Service.EnvironmentFile = [ credential.path ];
            };
          }
        ];
        homeManager = {
          programs.radicle = {
            enable = true;
            settings = lib.recursiveUpdate settings {
              node = {
                alias = cfg.alias or user.userName;
                limits.rate = {
                  inbound.fillRate = 5;
                  outbound.fillRate = 10;
                };
              };
            };
            # URI handlers use the user's explicit browser choice; avoid upstream autodetection.
            uri = lib.recursiveUpdate { web-rad.browser = null; } (cfg.uri or { });
          };
          services.radicle.node = {
            enable = true;
            args = "--log-logger systemd";
          };
          systemd.user.services.radicle-node.Unit.After = [ "default.target" ];
        };
      };

    radicle-seed =
      { host, ... }:
      let
        cfg = host.radicle-seed;
      in
      {
        includes = [
          den.aspects.sops
          den.aspects.caddy.radicle-seed-assets
        ]
        ++ lib.optional (host.caddy.enable or false) {
          nixos.services.caddy.virtualHosts.${cfg.domain}.extraConfig = ''
            reverse_proxy 127.0.0.1:8489
          '';
        };
        nixos = {
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
            settings = lib.recursiveUpdate settings {
              web = {
                bannerUrl = "https://radicle.${host.caddy.baseDomain}/images/youthlic-seed-header.png";
                avatarUrl = "https://radicle.${host.caddy.baseDomain}/images/youthlic-seed-avatar.jpg";
                description = "Private Seed Server.";
                pinned.repositories = [
                  "rad:z3gqcJUoA1n9HaHKufZs5FCSGazv5"
                  "rad:z4D5UCArafTzTQpDZNQRuqswh3ury"
                  "rad:z4V1sjrXqjvFdnCUbxPFqd5p4DtH5"
                  "rad:z6cFWeWpnZNHh9rUW8phgA3b5yGt"
                  "rad:z4Uh671FzoooaHjLvmtW9BtGMF9qm"
                ];
              };
              node = {
                alias = cfg.domain;
                listen = [ ];
                connect = [ ];
                externalAddresses = [ "${cfg.domain}:8776" ];
                limits.rate = {
                  inbound.fillRate = 5.0;
                  outbound.fillRate = 10.0;
                };
              };
            };
          };
        };
      };
  };
}
