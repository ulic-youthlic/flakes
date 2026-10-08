{ inputs, denOverlay, ... }: {
  den.overlays.gomod2nix =
    { final, prev }:
    inputs.gomod2nix.overlays.default final prev;

  den.overlays.buildGoTool = denOverlay.lib.inject (
    { final }:
    {
      pname,
      version ? "0.1.0",
      ...
    }@args:
    final.buildGoApplication (
      {
        inherit pname version;
        src = ../.;
        pwd = ../.;
        modules = ../gomod2nix.toml;
        inherit (final) go;
        subPackages = [ "go-modules/${pname}" ];
        meta.mainProgram = pname;
      }
      // args
    )
  );
}
