{pkgs, ...}: {
  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      man-pages
      man-pages-posix
      ;
  };
  documentation = {
    info.enable = true;
    nixos.enable = true;
    dev.enable = true;
    man = {
      enable = true;
      cache = {
        enable = true;
        generateAtRuntime = true;
      };
    };
  };
}
