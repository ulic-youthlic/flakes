{
  pkgs,
  inputs,
  ...
}:
{
  pinentry-selector = pkgs.callPackage ./pinentry-selector.nix { };
  immersive-translate =
    (pkgs.callPackage "${inputs.firefox-addons}/default.nix" { }).firefox-addons.immersive-translate;
}
// (
  let
    nur-xddxdd = (pkgs.callPackage "${inputs.nur-xddxdd}/default.nix" { });
  in
  pkgs.lib.genAttrs [ "rime-zhwiki" "rime-moegirl" ] (name: nur-xddxdd."${name}")
  // {
    rime-ice = nur-xddxdd.rime-ice.overrideAttrs {
      buildPhase = ''
        runHook preBuild

        runHook postBuild
      '';
    };
  }
)
