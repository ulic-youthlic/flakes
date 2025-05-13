{pkgs, ...}:
pkgs.radicle-explorer.withConfig {
  preferredSeeds = [
    {
      hostname = "seed.youthlic.fun";
      port = 443;
      scheme = "https";
    }
    {
      hostname = "ash.radicle.garden";
      port = 443;
      scheme = "https";
    }
    {
      hostname = "seed.radicle.xyz";
      port = 443;
      scheme = "https";
    }
    {
      hostname = "seed.radicle.garden";
      port = 443;
      scheme = "https";
    }
  ];
}
