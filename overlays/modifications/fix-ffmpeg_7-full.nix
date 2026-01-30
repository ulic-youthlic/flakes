{inputs, ...}: _final: prev: let
  inherit (prev.stdenv.hostPlatform) system;
  pkgs = import inputs.nixpkgs-485356 {
    localSystem = {
      inherit system;
    };
    config = {
      allowUnfree = true;
      cudaSupport = true;
    };
  };
in {
  ffmpeg_7-full = pkgs.ffmpeg_7-full;
}
