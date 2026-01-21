{
  lib,
  config,
  ...
}: let
  cfg = config.youthlic.programs.radicle;
in {
  options = {
    youthlic.programs.radicle = {
      enable = lib.mkEnableOption "radicle";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.radicle = {
      enable = true;
      settings = {
        publicExplorer = "https://app.radicle.xyz/nodes/$host/$rid$path";
        preferredSeeds = [
          "z6Mkmqogy2qEM2ummccUthFEaaHvyYmYBYh3dbe9W4ebScxo@rosa.radicle.xyz:8776"
          "z6MksmpU5b1dS7oaqF2bHXhQi1DWy2hB7Mh9CuN7y1DN6QSz@seed.radicle.xyz:8776"
          "z6MkrLMMsiPWUcNPHcRajuMi9mDfYckSoJyPwwnknocNYPm7@iris.radicle.xyz:8776"
        ];
        cli = {
          hints = true;
        };
        node = {
          alias = "youthlic";
          peers = {
            type = "dynamic";
          };
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
                fillRate = 5;
                capacity = 1024;
              };
              outbound = {
                fillRate = 10;
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
    sops.secrets."radicle/Tytonidae" = {};
    services.radicle.node = {
      enable = true;
      args = "--log-logger systemd";
      lazy.enable = true;
    };
    systemd.user.services."radicle-node".Service.EnvironmentFile = [config.sops.secrets."radicle/Tytonidae".path];
  };
}
