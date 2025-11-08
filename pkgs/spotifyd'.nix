{
  srcs,
  spotifyd,
  rustPlatform,
  ...
}: let
  inherit (srcs.spotifyd) src date version;
in
  spotifyd.overrideAttrs (
    _final: prev: {
      inherit src;
      version =
        if prev.version != "0.4.1"
        then
          throw ''
            Please remove <pkgs/spotifyd.nix>
          ''
        else "0-unstable-${date}-git${version}";
      cargoDeps = rustPlatform.fetchCargoVendor {
        inherit
          (prev)
          src
          ;
        hash = "sha256-WwShp1ebk89cBqRXqKDgbwGZraCDjQAOxoL4uEIq2aw=";
      };
    }
  )
