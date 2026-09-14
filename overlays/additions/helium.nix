{ inputs, ... }:
final: prev:
let
  inherit (prev)
    lib
    libGL
    vulkan-loader
    addDriverRunpath
    ;
  heliumOverlay = inputs.helium-nix.overlays.default final prev;
in
{
  helium = heliumOverlay.helium.overrideAttrs (
    _finalAttrs: prevAttrs: {
      postFixup =
        # bash
        ''
          ${prevAttrs.postFixup or ""}
          # Bundled loader only sees SwiftShader next to the binary. NixOS
          # vulkan-loader searches /run/opengl-driver for Intel/NVIDIA ICDs.
          # Dawn/WebGPU can still use Vulkan; Ozone Wayland compositing cannot
          # (wayland_surface_factory.cc rejects --enable-features=Vulkan).
          ln -sfn ${lib.getLib vulkan-loader}/lib/libvulkan.so.1 $out/opt/helium/libvulkan.so.1
          wrapProgram $out/bin/helium \
            --prefix LD_LIBRARY_PATH : ${
              lib.makeLibraryPath [
                libGL
                vulkan-loader
              ]
            } \
            --prefix LD_LIBRARY_PATH : ${addDriverRunpath.driverLink}/lib \
            --prefix XDG_DATA_DIRS : ${addDriverRunpath.driverLink}/share
        '';
    }
  );
}
