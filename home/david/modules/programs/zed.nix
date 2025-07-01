{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.david.programs.zed-editor;
in {
  options = {
    david.programs.zed-editor = {
      enable = lib.mkEnableOption "zed-editor";
    };
  };
  config = lib.mkIf cfg.enable {
    stylix.targets.zed.enable = false;
    programs.zed-editor = {
      enable = true;
      extensions = [
        "asciidoc"
        "basher"
        "cargo-tom"
        "deno"
        "docker-compose"
        "dockerfile"
        "fish"
        "git-firefly"
        "golangci-lint"
        "haskell"
        "html"
        "hurl"
        "idris2"
        "java"
        "java-eclipse-jdtls"
        "kdl"
        "kotlin"
        "lua"
        "make"
        "markdown-oxide"
        "neocmake"
        "nix"
        "python-refactoring"
        "python-requirements"
        "scheme"
        "toml"
        "typst"
        "xml"
        "zig"
        "typos"
        "ty"
        "ruff"
      ];
      extraPackages = with pkgs; [
        editor-runtime
      ];
      userSettings = {
        lsp = {
          ty = {
            binary = {
              path = lib.getExe pkgs.ty;
              arguments = ["server"];
            };
          };
        };
        languages = {
          Python = {
            language_servers = ["ty" "ruff" "pyright"];
            formatter = [
              {
                language_server = {
                  name = "ruff";
                };
              }
              {
                code_actions = {
                  "source.fixAll.ruff" = true;
                  "source.organizeImports.ruff" = true;
                };
              }
            ];
          };
          Nix = {
            language_servers = ["nixd" "nil"];
            formatter = {
              external = {
                command = "alejandra";
                arguments = ["--quiet" "--"];
              };
            };
          };
        };
        soft_wrap = "editor_width";
        autosave = "on_focus_change";
        auto_update = false;
        calls = {
          mute_on_join = true;
          share_on_join = false;
        };
        "format_on_save" = "off";
        ui_font_size = 20;
        buffer_font_size = 20;
        buffer_font_family = "Maple Mono NF CN";
        buffer_font_features = {
          "calt" = true;
          "zero" = true;
          "cv03" = true;
          "ss08" = true;
        };
        ui_font_family = "Source Han Sans SC";
        theme = "Gruvbox Dark Hard";
        vim_mode = true;
        vim = {
          # default_mode = "helix_normal";
        };
      };
    };
  };
}
