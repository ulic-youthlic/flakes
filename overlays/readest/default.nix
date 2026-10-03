{
  den.overlays.readest =
    { nvSources, prev }:
    {
      readest-web = prev.callPackage ./_package.nix {
        inherit (nvSources.readest) src date;
        rev = nvSources.readest.version;
      };
    };
}
