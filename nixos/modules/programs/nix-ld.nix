{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.youthlic.programs.nix-ld;
in
{
  options = {
    youthlic.programs.nix-ld = {
      enable = lib.mkEnableOption "nix-ld";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.nix-ld = {
      enable = true;
      # libraries = with pkgs; [
      #   stdenv.cc.cc
      #   zlib
      #   fuse3
      #   icu
      #   nss
      #   openssl
      #   curl
      #   expat
      # ];
    };
  };
}
