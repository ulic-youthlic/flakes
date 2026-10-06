{
  den.aspects.ghostty.homeManager =
    { lib, ... }:
    {
      catppuccin.ghostty.enable = false;
      programs.ghostty = {
        enable = true;
        settings = {
          font-family = [
            "MonoLisa"
            "Source Han Sans SC"
          ];
          font-size = lib.mkForce 17;
          theme = "Atom One Dark";
          background-opacity = 0.8;
          confirm-close-surface = "false";
        };
      };
    };
}
