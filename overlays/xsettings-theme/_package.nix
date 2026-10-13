{
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "xsettings-theme";
  version = "0.1.0";

  # The shared workspace root, like buildGoTool's `src = ../.` — but this file
  # sits one level deeper (overlays/<name>/), so it needs one more `..`.
  src = ../../.;

  # Paths are relative to src, so this is the workspace lockfile at the repo root.
  cargoLock.lockFile = ../../Cargo.lock;

  # Only this crate is built; the workspace may grow more members later.
  cargoBuildFlags = [
    "-p"
    "xsettings-theme"
  ];
  cargoTestFlags = [
    "-p"
    "xsettings-theme"
  ];

  # x11rb's RustConnection speaks the X protocol over the socket, so there is
  # no libX11/libxcb dependency and no C toolchain needed.
  meta = {
    description = "Set the XSETTINGS theme keys, preserving other entries";
    platforms = lib.platforms.linux;
    mainProgram = "xsettings-theme";
  };
}
