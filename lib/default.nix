final: _prev: {
  youthlic = {
    loadImports' = dir: f:
      if (builtins.pathExists dir && (builtins.readFileType dir) == "directory")
      then
        with final;
          pipe dir [
            builtins.readDir
            attrNames
            (filter (name: name != "default.nix"))
            f
            (map (name: dir + "/${name}"))
          ]
      else [];
    loadImports = with final; flip youthlic.loadImports' (x: x);
  };
}
