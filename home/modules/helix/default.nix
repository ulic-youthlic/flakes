{
  lib,
  pkgs,
  config,
  ...
}:
{
  options = {
    youthlic.programs.helix = {
      enable = lib.mkEnableOption "helix";
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
  config =
    let
      cfg = config.youthlic.programs.helix;
    in
    {
      programs.helix = lib.mkIf cfg.enable {
        enable = true;
        defaultEditor = true;
        extraPackages = cfg.extraPackages;
        settings =
          let
            config-file = builtins.readFile ./config.toml;
            config = builtins.fromTOML config-file;
          in
          config;
        languages = {
          language-server = {
            fish-lsp = {
              command = "fish-lsp";
              args = [
                "start"
              ];
            };
          };
          language = [
            {
              name = "kdl";
              formatter = {
                command = "kdlfmt";
                args = [
                  "format"
                  "-"
                ];
              };
            }
            {
              name = "just";
              formatter = {
                command = "just";
                args = [
                  "--dump"
                ];
              };
            }
            {
              name = "nix";
              formatter = {
                command = "nixfmt";
                args = [ "-" ];
              };
            }
            {
              name = "xml";
              formatter = {
                command = "xmllint";
                args = [
                  "--format"
                  "-"
                ];
              };
            }
            {
              name = "typst";
              formatter = {
                command = "typstyle";
              };
            }
            {
              name = "c";
              formatter = {
                command = "clang-format";
              };
            }
            {
              name = "cpp";
              formatter = {
                command = "clang-format";
              };
            }
            {
              name = "python";
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
              ];
            }
            {
              name = "go";
              formatter = {
                command = "goimports";
              };
            }
            {
              name = "awk";
              formatter = {
                command = "awk";
                timeout = 5;
                args = [
                  "--file=/dev/stdin"
                  "--pretty-print=/dev/stdout"
                ];
              };
            }
            {
              name = "fish";
              language-servers = [
                "fish-lsp"
              ];
            }
            {
              name = "yaml";
              formatter = {
                command = "deno";
                args = [
                  "fmt"
                  "-"
                  "--ext"
                  "yaml"
                ];
              };
            }
            {
              name = "html";
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
            }
            {
              name = "css";
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
            }
            {
              name = "toml";
              formatter = {
                command = "taplo";
                args = [
                  "fmt"
                  "-"
                ];
              };
            }
            {
              name = "markdown";
              formatter = {
                command = "deno";
                args = [
                  "fmt"
                  "-"
                  "--ext"
                  "md"
                ];
              };
            }
            {
              name = "json";
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
            }
            {
              name = "jsonc";
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
            }
          ];
        };
      };
    };
}
