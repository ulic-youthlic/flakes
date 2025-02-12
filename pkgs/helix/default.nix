{
  lib,
  pkgs,
  inputs,
  ...
}@args:
let
  inherit (inputs.helix.packages."${pkgs.system}") helix helix-unwrapped;
  helix-core = helix-unwrapped.overrideAttrs {
    HELIX_DEFAULT_RUNTIME = "${grammarRuntime}";
  };
  helix-wrapped = (helix.override grammarConfig).passthru.wrapper helix-core;
  grammars = import ./grammars args;
  grammarOverlays = grammars.overlays;
  grammarRuntime = grammars.runtime;
  grammarConfig = {
    inherit grammarOverlays;
  };
  runtimeInputs = (
    with pkgs;
    [
      idris2Packages.idris2Lsp
      lua-language-server
      bash-language-server
      hurl
      cmake-language-server
      kdlfmt
      rustfmt
      clang-tools
      libxml2
      typstyle
      pyright
      ruff
      gotools
      yaml-language-server
      taplo
      markdown-oxide
      nixd
      deno
      nixfmt-rfc-style
      vscode-langservers-extracted
      fish-lsp
      gopls
      golangci-lint-langserver
      tinymist
      delve
      # lldb
      rust-analyzer
      nil
      haskell-language-server
      neocmakelsp
    ]
  );
in
pkgs.symlinkJoin {
  pname = "helix-wrapped";
  version = helix-wrapped.version;
  paths = [ helix-wrapped ];
  inherit (helix-wrapped) meta;
  buildInputs = [
    pkgs.makeWrapper
  ];
  postBuild = ''
    wrapProgram $out/bin/hx \
    --suffix PATH : ${lib.makeBinPath runtimeInputs}
  '';
}
