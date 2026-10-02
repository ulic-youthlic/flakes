{
  den.overlays.helix =
    { prev }:
    let
      # Bump tree-sitter-haskell to fix GCC 16 heap corruption, queries need to follow the new grammar
      # TODO: drop once https://github.com/helix-editor/helix/pull/16331 reaches nixpkgs
      haskellPatches = map prev.fetchpatch [
        {
          name = "helix-bump-haskell-grammar.patch";
          url = "https://github.com/helix-editor/helix/commit/07efa987d718fc7fe5e505cfa01ab94484358957.patch";
          hash = "sha256-yPGoYkhRfo1VZUmwGlCsJtdhlexiyC7u2tAKSuLAZXc=";
        }
        {
          name = "helix-fix-haskell-type-synonym-tag-query.patch";
          url = "https://github.com/helix-editor/helix/commit/99880ad01d0362cb91987534e72aca8b2ebf28b8.patch";
          hash = "sha256-Omvsw3W+JQw3ktQjT6HomfyQzKNeIAWiqqTJkRrnLsA=";
        }
      ];
      haskellGrammar = {
        nurl = {
          fetcher = "fetchFromGitHub";
          args = {
            owner = "tree-sitter";
            repo = "tree-sitter-haskell";
            rev = "97288e585b0bd44199720280d067fa35bacd81ff";
            hash = "sha256-R4KAAaBoDUGuQtR2U+0xdB9iLclWBrm+/blqsCX5ZjQ=";
          };
        };
        subpath = null;
      };
      # Only the runtime (queries + grammars) of the wrapper changes, the unwrapped binary is kept as-is
      helix = prev.helix // {
        override =
          args:
          prev.helix.override (
            args
            // {
              helix-unwrapped = args.helix-unwrapped // {
                src = prev.applyPatches {
                  inherit (args.helix-unwrapped) src;
                  patches = haskellPatches;
                };
              };
              lockedGrammars = args.lockedGrammars // {
                haskell = haskellGrammar;
              };
            }
          );
      };
    in
    {
      steelix = (prev.steelix.override { inherit helix; }).overrideAttrs (finalAttrs: {
        passthru = finalAttrs.passthru or { } // {
          languages = prev.lib.pipe "${finalAttrs.passthru.unwrapped.src}/languages.toml" [
            builtins.readFile
            fromTOML
          ];
        };
      });
    };
}
