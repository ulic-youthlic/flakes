{
  lib,
  config,
  options,
  ...
}: let
  cfg = config.youthlic;
in {
  options = {
    youthlic.plugins = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({
        name,
        lib,
        ...
      }: {
        freeformType = lib.types.anything;
        options = {
          enable = lib.mkEnableOption "nvimPlugins.${name}";
        };
      }));
      default = {};
    };
  };
  config = let
    enabledPlugins = lib.filterAttrs (_name: value: value.enable) cfg.plugins;
  in
    lib.mkMerge [
      {
        plugins = enabledPlugins;
      }
      {
        plugins = lib.pipe enabledPlugins [
          builtins.attrNames
          (lib.filter (name: options.plugins.${name} ? luaConfig))
          (map (name:
            lib.nameValuePair name {
              luaConfig.post =
                #lua
                ''
                  _M.load("${name}")
                '';
            }))
          lib.listToAttrs
        ];
      }
    ];
}
