{
  den.overlays.wshowkeys-mao =
    { nvSources, prev }:
    let
      inherit (nvSources) wshowkeys-mao;
    in
    {
      wshowkeys = prev.wshowkeys.overrideAttrs {
        inherit (wshowkeys-mao) src;
        pname = "wshowkeys-mao";
        version = wshowkeys-mao.date + "-" + wshowkeys-mao.version;
      };
    };
}
