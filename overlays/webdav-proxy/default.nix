{
  den.overlays.webdav-proxy = { prev }: {
    webdav-proxy = prev.callPackage ./package.nix { };
  };
}
