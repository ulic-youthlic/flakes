{
  den.overlays.readest =
    { nvSources, prev }:
    {
      readest-web = prev.callPackage ./package.nix {
        inherit (nvSources.readest) src date;
        rev = nvSources.readest.version;
      };
    };
}
