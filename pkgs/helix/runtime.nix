{
  lib,
  srcs,
  stdenv,
  runCommandNoCCLocal,
  ...
}: let
  buildGrammar = grammar:
    stdenv.mkDerivation {
      pname = "helix-tree-sitter-${grammar.name}";
      version = grammar.version;
      src = grammar.src;
      # sourceRoot = "source";

      dontConfigue = true;

      FLAGS = [
        "-Isrc"
        "-g"
        "-O3"
        "-fPIC"
        "-fno-exceptions"
        "-Wl,-z,relro,-z,now"
      ];

      NAME = grammar.name;

      buildPhase = ''
        runHook preBuild

        if [[ -e src/scanner.cc ]]; then
          $CXX -c src/scanner.cc -o scanner.o $FLAGS
        elif [[ -e src/scanner.c ]]; then
          $CC -c src/scanner.c -o scanner.o $FLAGS
        fi

        $CC -c src/parser.c -o parser.o $FLAGS
        $CXX -shared -o $NAME.so *.o

        ls -al

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir $out
        mv $NAME.so $out/

        runHook postInstall
      '';

      fixupPhase = lib.optionalString stdenv.isLinux ''
        runHook preFixup

        $STRIP $out/$NAME.so

        runHook postFixup
      '';
    };
  grammars = srcs |> lib.filterAttrs (key: _: lib.hasPrefix "tree-sitter-" key);

  queries =
    grammars
    |> lib.mapAttrsToList (
      _: value: ''
        mkdir -p $out/${value.name}

        ln -s ${value.src}/queries/* $out/${value.name}/
      ''
    );
  grammarLinks =
    grammars
    |> builtins.mapAttrs (
      _: v: {
        inherit (v) name;
        value = buildGrammar v;
      }
    )
    |> lib.mapAttrsToList (_: value: "ln -s ${value.value}/${value.name}.so $out/${value.name}.so");
  grammarDir = runCommandNoCCLocal "helix-grammars" {} ''
    mkdir -p $out

    ${builtins.concatStringsSep "\n" grammarLinks}
  '';
  queryDir = runCommandNoCCLocal "helix-query" {} ''
    mkdir -p $out

    ${builtins.concatStringsSep "\n" queries}
  '';
in
  runCommandNoCCLocal "helix-runtime" {} ''
    mkdir -p $out

    ln -s ${grammarDir} $out/grammars
    ln -s ${queryDir} $out/queries
  ''
