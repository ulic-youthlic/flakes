{
  den.overlays.radicle-explorer =
    { prev }:
    let
      inherit (prev) radicle-explorer;
    in
    {
      radicle-explorer = radicle-explorer.withConfig {
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
      };
    };
}
