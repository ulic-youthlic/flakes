{
  den.overlays.webdav-proxy =
    {
      final,
      prev,
      buildGoTool,
    }:
    {
      webdav-proxy = prev.callPackage ./_package.nix { inherit buildGoTool; };
    };
}
