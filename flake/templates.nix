{
  flake-parts-lib,
  lib,
  ...
}: let
  rootPath = ./..;
in {
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
