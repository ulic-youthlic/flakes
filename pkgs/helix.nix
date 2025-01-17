{
  lib,
  pkgs,
  inputs,
  ...
}:
pkgs.runCommand "helix-wrapped"
  {
    buildInputs = [ pkgs.makeWrapper ];
  }
  ''
    mkdir -p $out/bin
    makeWrapper "${lib.getExe inputs.helix.packages."${pkgs.system}".default}" $out/bin/hx \
    --suffix PATH : ${
      lib.makeBinPath (
        with pkgs;
        [
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
        ]
      )
    }
  ''
