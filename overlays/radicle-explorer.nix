{
  den.overlays.radicle-explorer =
    { prev }:
    let
      inherit (prev) radicle-explorer;
    in
    {
      radicle-explorer =
        (radicle-explorer.withConfig {
          preferredSeeds = [
            {
              hostname = "seed.youthlic.social";
              port = 443;
              scheme = "https";
            }
            {
              hostname = "rosa.radicle.network";
              port = 443;
              scheme = "https";
            }
            {
              hostname = "seed.radicle.dev";
              port = 443;
              scheme = "https";
            }
            {
              hostname = "iris.radicle.network";
              port = 443;
              scheme = "https";
            }
          ];
        }).overrideAttrs
          (finalAttrs: {
            postInstall = (finalAttrs.postInstall or "") + ''
              ln -s ${./../assets/radicle-explorer/youthlic-seed-header.png} $out/images/youthlic-seed-header.png
              ln -s ${./../assets/radicle-explorer/youthlic-seed-avatar.jpg} $out/images/youthlic-seed-avatar.jpg
            '';
          });
    };
}
