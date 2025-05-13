{pkgs, ...}:
(pkgs.radicle-explorer.withConfig {
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
}).overrideAttrs (prev: {
  postInstall =
    (prev.postInstall or "")
    + ''
      ln -s ${./youthlic-seed-header.png} $out/images/youthlic-seed-header.png
      ln -s ${./youthlic-seed-avatar.jpg} $out/images/youthlic-seed-avatar.jpg
    '';
})
