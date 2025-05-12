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
    };
  };
  config = lib.mkIf cfg.enable {
    services.radicle = {
      enable = true;
      node.listenAddress = "127.0.0.1";
      inherit (cfg) publicKey privateKeyFile;
      settings = {
        publicExplorer = "https://app.radicle.xyz/nodes/$host/$rid$path";
        preferredSeeds = [
          "z6Mkmqogy2qEM2ummccUthFEaaHvyYmYBYh3dbe9W4ebScxo@ash.radicle.garden:8776"
          "z6MksmpU5b1dS7oaqF2bHXhQi1DWy2hB7Mh9CuN7y1DN6QSz@seed.radicle.xyz:8776"
          "z6MkrLMMsiPWUcNPHcRajuMi9mDfYckSoJyPwwnknocNYPm7@seed.radicle.garden:8776"
        ];
        web = {
          pinned = {
            repositories = [];
          };
        };
        cli = {
          hints = true;
        };
        node = {
          alias = "youthlic";
          listen = [];
          peers = {
            type = "dynamic";
          };
          connect = [];
          extrnalAddresses = [];
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
  };
}
