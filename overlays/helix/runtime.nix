{ denOverlay, ... }: {
  den.overlays.helix.runtime = denOverlay.lib.inject (
    { nvSources, prev }:
    let
      inherit (prev) runCommandLocal stdenv lib;
      buildGrammar =
        grammar:
        stdenv.mkDerivation {
          pname = "helix-tree-sitter-${grammar.name}";
          version = grammar.version;
          src = grammar.src;

          dontConfigure = true;

          FLAGS = [
            "-Isrc"
            "-g"
            "-O3"
            "-fPIC"
            "-fno-exceptions"
            "-Wl,-z,relro,-z,now"
          ];

          NAME = grammar.name;

          buildPhase = # bash
            ''
              runHook preBuild

              if [[ -e src/scanner.cc ]]; then
                $CXX -c src/scanner.cc -o scanner.o $FLAGS
              elif [[ -e src/scanner.c ]]; then
                $CC -c src/scanner.c -o scanner.o $FLAGS
              fi

              runHook postBuild
            '';

          installPhase = # bash
            ''
              runHook preInstall

              mkdir $out
              mv $NAME.so $out/

              runHook postInstall
            '';

          fixupPhase =
            lib.optionalString stdenv.hostPlatform.isLinux # bash
              ''
                runHook preFixup

                $STRIP $out/$NAME.so

                runHook postFixup
              '';
        };
      grammars = with lib; pipe nvSources [ (filterAttrs (key: _: hasPrefix "tree-sitter-" key)) ];
      queries =
        with lib;
        pipe grammars [
          (mapAttrsToList (
            _: value: # bash
            ''
              mkdir -p $out/${value.name}
              ln -s ${value.src}/queries/* $out/${value.name}/
            ''
          ))
        ];
      grammarLinks =
        with lib;
        pipe grammars [
          (builtins.mapAttrs (
            _: v: {
              inherit (v) name;
              value = buildGrammar v;
            }
          ))
          (mapAttrsToList (
            _: value: # bash
            ''
              ln -s ${value.value}/${value.name}.so $out/${value.name}.so
            ''
          ))
        ];
      grammarDir =
        runCommandLocal "helix-grammars" { } # bash
          ''
            mkdir -p $out

            ${builtins.concatStringsSep "\n" grammarLinks}
          '';
      queryDir =
        runCommandLocal "helix-query" { } # bash
          ''
            mkdir -p $out

            ${builtins.concatStringsSep "\n" queries}
          '';
    in
    runCommandLocal "helix-runtime" { } # bash
      ''
        mkdir -p $out

        ln -s ${grammarDir} $out/grammars
        ln -s ${queryDir} $out/queries
      ''
  );
}
