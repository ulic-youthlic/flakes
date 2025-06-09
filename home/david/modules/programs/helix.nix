{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.david.programs.helix;
in {
  options = {
    david.programs.helix = {
      enable = lib.mkEnableOption "helix";
    };
  };
  config = lib.mkIf cfg.enable {
    youthlic.programs.helix = {
      enable = true;
      extraPackages = with pkgs; [
        nixfmt-rfc-style
        idris2Packages.idris2Lsp
        lua-language-server
        bash-language-server
        shfmt
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
        marksman
        nixd
        deno
        alejandra
        vscode-langservers-extracted
        fish-lsp
        tailwindcss-language-server
        gopls
        golangci-lint-langserver
        tinymist
        delve
        lldb
        rust-analyzer
        # nil
        haskell-language-server
        neocmakelsp
        jdt-language-server
        zls
      ];
    };
  };
}
