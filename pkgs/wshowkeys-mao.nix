{
  srcs,
  wshowkeys,
}: let
  inherit (srcs) wshowkeys-mao;
in
  wshowkeys.overrideAttrs (
    _final: _prev: {
      inherit (wshowkeys-mao) src;
      pname = "wshowkeys-mao";
      version = wshowkeys-mao.date + "-" + wshowkeys-mao.version;
    }
  )
