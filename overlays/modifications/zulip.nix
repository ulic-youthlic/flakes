{ ... }: _final: prev: {
  zulip = prev.zulip.overrideAttrs (
    _finalAttrs: prevAttrs: {
      nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ prev.makeWrapper ];
      postInstall =
        #bash
        ''
          wrapProgram $out/bin/zulip \
            --set NIXOS_OZONE_WL 1 \
            --add-flags '--wayland-text-input-version=3'
        '';
    }
  );
}
