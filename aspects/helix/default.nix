{ lib, ... }:
{
  den.aspects.helix.xdg-mime = lib.genAttrs [
    "text/plain"
    "text/english"
    "text/markdown"
    "text/csv"
    "text/tab-separated-values"
    "text/css"
    "text/javascript"
    "text/xml"
    "text/yaml"
    "text/x-c"
    "text/x-c++"
    "text/x-chdr"
    "text/x-c++hdr"
    "text/x-csrc"
    "text/x-c++src"
    "text/x-java"
    "text/x-makefile"
    "text/x-nix"
    "text/x-python"
    "text/x-rust"
    "text/x-go"
    "text/x-lua"
    "text/x-sh"
    "text/x-tex"
    "application/javascript"
    "application/json"
    "application/ld+json"
    "application/toml"
    "application/xml"
    "application/yaml"
    "application/x-yaml"
    "application/x-shellscript"
    "application/x-zerosize"
  ] (_: lib.mkBefore [ "Helix.desktop" ]);

  den.aspects.helix.nixos =
    { pkgs, ... }:
    {
      environment = {
        systemPackages = [ pkgs.steelix ];
        variables.EDITOR = "hx";
      };
    };

  den.aspects.helix.homeManager =
    {
      lib,
      pkgs,
      ...
    }:
    let
      package = pkgs.steelix;
      defaults = lib.listToAttrs (
        map (
          language: lib.nameValuePair language.name (lib.removeAttrs language [ "name" ])
        ) package.passthru.languages.language
      );
      languageSettings = lib.recursiveUpdate defaults {
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
    in
    {
      home.packages = [ pkgs.steel ];
      catppuccin.helix.enable = false;
      programs.helix = {
        enable = true;
        inherit package;
        defaultEditor = true;
        settings = lib.fromTOML (builtins.readFile ./config.toml);
        extraPackages = [ pkgs.editor-runtime ];
        languages = {
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
          language = lib.mapAttrsToList (
            name: language:
            {
              inherit name;
            }
            // language
            // {
              language-servers = lib.unique ((language.language-servers or [ ]) ++ [ "typos-lsp" ]);
            }
          ) languageSettings;
        };
      };
    };
}
