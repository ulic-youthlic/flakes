{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    treefmt = {
      programs = {
        alejandra = {
          enable = true;
          excludes = ["_sources/*.nix"];
        };
        biome = {
          enable = true;
          includes = ["*.json"];
          excludes = ["_sources/*.json"];
          settings = {
            formatter.indentStyle = "space";
            javascript.formatter.enabled = false;
            css.formatter.enabled = false;
          };
        };
        dprint = {
          enable = true;
          includes = [
            "*.md"
            "*.toml"
            "*.yaml"
          ];
          excludes = ["secrets/*.yaml"];
          settings = {
            plugins = pkgs.dprint-plugins.getPluginList (
              plugins:
                with plugins; [
                  dprint-plugin-toml
                  dprint-plugin-markdown
                  g-plane-pretty_yaml
                ]
            );
          };
        };
        just = {
          enable = true;
          includes = [".justfile"];
        };
        typos = let
          config = with lib;
            pipe ./.typos.toml [
              builtins.readFile
              fromTOML
            ];
        in {
          enable = true;
          includes = ["*"];
          excludes = ["assets/*"] ++ config.files.extend-exclude;
          configFile = toString ./.typos.toml;
          # Disable all extra option in treefmt module.
          # Use config file.
          sort = false;
          isolated = false;
          hidden = false;
          noIgnore = false;
          noIgnoreDot = false;
          noIgnoreGlobal = false;
          noIgnoreParent = false;
          noIgnoreVCS = false;
          binary = false;
          noCheckFilenames = false;
          noCheckFiles = false;
          noUnicode = false;
        };
      };
    };
  };
}
