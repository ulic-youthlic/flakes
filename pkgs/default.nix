{
  pkgs,
  inputs,
  ...
}:
{
  pinentry-selector = pkgs.callPackage ./pinentry-selector.nix { };
}
// (
  let
    firefox-addons = (pkgs.callPackage "${inputs.firefox-addons}/default.nix" { }).firefox-addons;
  in
  pkgs.lib.genAttrs [ "immersive-translate" "tridactyl" ] (name: firefox-addons."${name}")
)
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
