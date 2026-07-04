{
  perSystem = { lib, ... }: {
    treefmt.programs = {
      nixfmt = {
        enable = true;
        excludes = [ "_sources/*.nix" ];
      };
      oxfmt =
        let
          oxfmtConfig =
            with lib;
            pipe ./.oxfmtrc.json [
              builtins.readFile
              builtins.fromJSON
            ];
        in
        {
          enable = true;
          includes = [
            "*.json"
            "*.md"
            "*.toml"
            "*.yaml"
          ];
          excludes = oxfmtConfig.ignorePatterns;
        };
      just = {
        enable = true;
        includes = [ ".justfile" ];
      };
      typos =
        let
          config =
            with lib;
            pipe ./.typos.toml [
              builtins.readFile
              fromTOML
            ];
        in
        {
          enable = true;
          includes = [ "*" ];
          excludes = [ "assets/*" ] ++ config.files.extend-exclude;
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
}
