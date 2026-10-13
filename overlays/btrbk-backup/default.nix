{
  den.overlays.btrbk-backup =
    {
      final,
      prev,
      buildBashTool,
    }:
    {
      btrbk-backup = prev.callPackage ./_package.nix { inherit buildBashTool; };
    };
}
