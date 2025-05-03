{rootPath, ...}: {
  flake-parts-lib,
  lib,
  ...
}: {
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      templates = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
      };
    };
  };
  config = {
    flake.templates = import (rootPath + "/templates");
  };
}
