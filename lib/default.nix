final: _prev: {
  youthlic = {
    loadImports' = dir: f:
      final.pipe dir [
        final.youthlic.loadImports
        f
      ];
    loadImports = dir:
      with final;
        if !(pathExists dir && builtins.readFileType dir == "directory")
        then []
        else let
          items = pipe dir [builtins.readDir attrNames];
        in
          pipe items [
            (concatMap
              (name: let
                path = dir + "/${name}";
                type = builtins.readFileType path;
              in
                if type == "directory"
                then
                  if pathExists (path + "/default.nix")
                  then [path]
                  else youthlic.loadImports path
                else if type == "regular"
                then
                  if hasSuffix ".nix" name
                  then [path]
                  else []
                else []))
            (filter (name: !hasSuffix "/default.nix" (toString name)))
          ];
  };
}
