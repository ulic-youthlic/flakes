{
  den.aspects.obs.nixos =
    { pkgs, ... }:
    {
      programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          obs-source-record
          obs-pipewire-audio-capture
        ];
        enableVirtualCamera = true;
      };
    };
}
