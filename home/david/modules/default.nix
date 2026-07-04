{ lib, ... }: {
  imports = lib.youthlic.loadImports ./.;
  config = {
    youthlic.programs = {
      zoxide.enable = true;
      fzf.enable = true;
      yazi.enable = true;
      eza.enable = true;
    };
    services.mpris-proxy.enable = true;
  };
}
