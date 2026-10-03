{
  den.overlays.helix = { prev }: {
    steelix = prev.steelix.overrideAttrs (finalAttrs: {
      passthru = finalAttrs.passthru or { } // {
        languages = prev.lib.pipe "${finalAttrs.passthru.unwrapped.src}/languages.toml" [
          builtins.readFile
          fromTOML
        ];
      };
    });
  };
}
