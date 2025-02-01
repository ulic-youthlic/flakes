{
  pkgs,
  inputs,
  ...
}:
{
  pinentry-selector = pkgs.callPackage ./pinentry-selector.nix { };
  helix = pkgs.callPackage ./helix.nix { inherit inputs; };
}
// (
  let
    firefox-addons = (pkgs.callPackage "${inputs.nur-rycee}/pkgs/firefox-addons/default.nix" { });
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
