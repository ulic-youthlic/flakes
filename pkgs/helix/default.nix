{
  lib,
  pkgs,
  inputs,
  ...
}@args:
let
  inherit (inputs.helix.packages."${pkgs.system}") helix;
  runtime = import ./runtime args;
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
      lldb
      rust-analyzer
      nil
      haskell-language-server
      neocmakelsp
    ]
  );
in
pkgs.symlinkJoin {
  name = "helix-wrapped";
  paths = [ helix ];
  inherit (helix) meta;
  buildInputs = [
    pkgs.makeWrapper
  ];
  postBuild = ''
    wrapProgram $out/bin/hx \
    --suffix PATH : ${lib.makeBinPath runtimeInputs} \
    --set HELIX_RUNTIME ${runtime}
  '';
}
