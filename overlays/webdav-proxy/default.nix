{
  den.overlays.webdav-proxy = { prev }: {
    webdav-proxy = prev.callPackage ./_package.nix { };
  };
}
