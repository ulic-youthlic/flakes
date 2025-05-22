{
  pkgs,
  srcs,
}: let
  inherit (srcs) wshowkeys-mao;
in
  pkgs.wshowkeys.overrideAttrs (final: prev: {
    inherit (wshowkeys-mao) src;
    pname = "wshowkeys-mao";
    version = wshowkeys-mao.date + "-" + wshowkeys-mao.version;
  })
