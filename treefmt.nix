{
  perSystem = {pkgs, ...}: {
    treefmt = {
      programs = {
        alejandra = {
          enable = true;
          excludes = ["pkgs/_sources/*.nix"];
        };
        biome = {
          enable = true;
          includes = ["*.json"];
          excludes = ["pkgs/_sources/*.json"];
          settings = {
            javascript.formatter.enabled = false;
            css.formatter.enabled = false;
          };
        };
        dprint = {
          enable = true;
          includes = ["*.md" "*.toml" "*.yaml"];
          excludes = ["secrets/*.yaml"];
          settings = {
            plugins = pkgs.dprint-plugins.getPluginList (plugins:
              with plugins; [
                dprint-plugin-toml
                dprint-plugin-markdown
                g-plane-pretty_yaml
              ]);
          };
        };
        just = {
          enable = true;
          includes = [".justfile"];
        };
        typos = let
          config = ./.typos.toml |> builtins.readFile |> builtins.fromTOML;
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
