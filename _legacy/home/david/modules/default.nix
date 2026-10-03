{ lib, ... }: {
  imports = lib.youthlic.loadImports ./.;
  config = {
    services.mpris-proxy.enable = true;
  };
}
