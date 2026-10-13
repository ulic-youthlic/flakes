{
  den.overlays.xsettings-theme =
    { prev }:
    {
      xsettings-theme = prev.callPackage ./_package.nix { };
    };
}
