{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.youthlic.programs.helix;
  defaultLanguagesSettings = config.programs.helix.package.passthru.languages.language;
in
{
  options = {
    youthlic.programs.helix = {
      enable = lib.mkEnableOption "helix";
      languageSettings = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule (
            { ... }: {
              freeformType = lib.types.anything;
              options = {
                language-servers = lib.mkOption {
                  type = lib.types.listOf (lib.types.either lib.types.str lib.types.anything);
                  default = [ "typos-lsp" ];
                  example = [ "rust-analyzer" ];
                  apply = lib.unique;
                };
              };
            }
          )
        );
        default = lib.pipe defaultLanguagesSettings [
          (map (lang: lib.nameValuePair lang.name (lib.removeAttrs lang [ "name" ])))
          lib.listToAttrs
        ];
        apply = lib.mapAttrsToList (name: value: { inherit name; } // value);
      };
      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        example = (
          with pkgs;
          [
            deno
          ]
        );
        description = ''
          extra packages for helix lsp and formatter
        '';
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = lib.singleton pkgs.steel;
      programs.helix = {
        enable = true;
        defaultEditor = true;
        extraPackages = cfg.extraPackages;
        settings =
          with lib;
          pipe ./config.toml [
            builtins.readFile
            fromTOML
          ];
        languages = lib.recursiveUpdate {
          language-server = {
            neocmakelsp = {
              command = "neocmakelsp";
              args = [
                "stdio"
              ];
            };
            fish-lsp = {
              command = "fish-lsp";
              args = [
                "start"
              ];
            };
            ty = {
              command = "ty";
              args = [
                "server"
              ];
            };
            typos-lsp = {
              command = "typos-lsp";
            };
          };
        } { language = cfg.languageSettings; };
      };
    })
    (lib.mkIf cfg.enable {
      youthlic.programs.helix.languageSettings = lib.pipe defaultLanguagesSettings [
        (map ({ name, ... }: lib.nameValuePair name { language-servers = [ "typos-lsp" ]; }))
        lib.listToAttrs
      ];
    })
    (lib.mkIf cfg.enable {
      youthlic.programs.helix.languageSettings =
        lib.recursiveUpdate
          (lib.pipe defaultLanguagesSettings [
            (map (lang: lib.nameValuePair lang.name (lib.removeAttrs lang [ "name" ])))
            lib.listToAttrs
          ])
          {
            cmake = {
              language-servers = [
                "neocmakelsp"
                "cmake-language-server"
              ];
            };
            kdl = {
              formatter = {
                command = "kdlfmt";
                args = [
                  "format"
                  "-"
                ];
              };
            };
            just = {
              formatter = {
                command = "just";
                args = [
                  "--dump"
                ];
              };
            };
            nix = {
              formatter = {
                command = "nixfmt";
              };
            };
            xml = {
              formatter = {
                command = "xmllint";
                args = [
                  "--format"
                  "-"
                ];
              };
            };
            typst = {
              formatter = {
                command = "typstyle";
              };
            };
            c = {
              formatter = {
                command = "clang-format";
              };
            };
            cpp = {
              formatter = {
                command = "clang-format";
              };
            };
            python = {
              formatter = {
                command = "ruff";
                args = [
                  "format"
                  "-s"
                  "--line-length"
                  "88"
                  "-"
                ];
              };
              language-servers = [
                "pyright"
                "ruff"
                "ty"
              ];
            };
            go = {
              formatter = {
                command = "goimports";
              };
            };
            awk = {
              formatter = {
                command = "awk";
                timeout = 5;
                args = [
                  "--file=/dev/stdin"
                  "--pretty-print=/dev/stdout"
                ];
              };
            };
            fish = {
              language-servers = [
                "fish-lsp"
              ];
            };
            yaml = {
              formatter = {
                command = "deno";
                args = [
                  "fmt"
                  "-"
                  "--ext"
                  "yaml"
                ];
              };
            };
            html = {
              formatter = {
                command = "deno";
                args = [
                  "fmt"
                  "-"
                  "--ext"
                  "html"
                ];
              };
              language-servers = [
                "vscode-html-language-server"
              ];
            };
            css = {
              formatter = {
                command = "deno";
                args = [
                  "fmt"
                  "-"
                  "--ext"
                  "css"
                ];
              };
              language-servers = [
                "vscode-css-language-server"
              ];
            };
            toml = {
              formatter = {
                command = "taplo";
                args = [
                  "fmt"
                  "-"
                ];
              };
            };
            markdown = {
              formatter = {
                command = "deno";
                args = [
                  "fmt"
                  "-"
                  "--ext"
                  "md"
                ];
              };
            };
            json = {
              language-servers = [
                "vscode-json-language-server"
              ];
              formatter = {
                command = "deno";
                args = [
                  "fmt"
                  "-"
                  "--ext"
                  "json"
                ];
              };
            };
            jsonc = {
              language-servers = [
                "vscode-json-language-server"
              ];
              formatter = {
                command = "deno";
                args = [
                  "fmt"
                  "-"
                  "--ext"
                  "jsonc"
                ];
              };
            };
          };
    })
  ];
}
