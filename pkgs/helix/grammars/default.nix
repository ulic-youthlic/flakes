{ lib, pkgs, ... }:
let
  inherit (pkgs) stdenv;
  buildGrammar =
    grammar:
    let
      source = sources."${grammar.name}";
    in
    stdenv.mkDerivation {
      pname = "helix-tree-sitter-${grammar.name}";
      version = grammar.rev;
      src = source;
      sourceRoot = "source";

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
  grammars = map (file: import file) grammarFiles;
  sources = lib.listToAttrs (
    map (grammar: {
      inherit (grammar) name;
      value = builtins.fetchTree {
        type = "github";
        inherit (grammar) owner repo rev; };
    }) grammars
  );
  queries = lib.mapAttrsToList (name: value: ''
    mkdir -p $out/queries/${name}
    cp ${value}/queries/* $out/queries/${name}/
  '') sources;
  runtime = pkgs.runCommand "helix-default-runtime" { } ''
    mkdir -p $out
    ${builtins.concatStringsSep "\n" queries}
  '';
  builtGrammars = lib.listToAttrs (
    map (grammar: {
      inherit (grammar) name;
      value = buildGrammar grammar;
    }) grammars
  );
  grammarFiles = [
    ./idris.nix
  ];
in
{
  overlays = [
    (final: prev: lib.filterAttrs (n: v: !(builtins.hasAttr n prev)) builtGrammars)
  ];
  inherit runtime;
}
