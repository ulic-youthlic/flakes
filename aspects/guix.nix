{
  den.aspects.guix.nixos =
    { options, ... }:
    {
      services.guix = {
        enable = true;
        gc = {
          enable = true;
          dates = "weekly";
        };
        substituters.urls = [
          "https://mirror.sjtu.edu.cn/guix/"
        ]
        ++ options.services.guix.substituters.urls.default;
      };
    };
}
