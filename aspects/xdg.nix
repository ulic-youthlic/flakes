{ den, ... }:
{
  den.quirks.xdg-mime.description = "Default MIME applications contributed by application aspects.";

  # Collect once per host, including declarations from its users.
  den.schema.host.includes = [ den.aspects.xdg ];
  den.schema.user.includes = [ den.policies.xdg-to-host ];

  # Den uses these argument names to select the host/user scope.
  den.policies.xdg-to-host =
    { host, user, ... }:
    let
      inherit (den.lib.policy) pipe;
    in
    [ (pipe.from "xdg-mime" [ pipe.expose ]) ];

  den.aspects.xdg.nixos =
    { xdg-mime, lib, ... }:
    let
      # Merge lists before NixOS's MIME option converts them to strings.
      defaults =
        lib.mergeDefinitions [ "xdg" "mime" "defaultApplications" ]
          (lib.types.attrsOf (lib.types.listOf lib.types.str))
          (
            map (value: {
              file = "xdg-mime quirk";
              inherit value;
            }) xdg-mime
          );
    in
    {
      xdg.mime.defaultApplications = lib.mapAttrs (_: lib.unique) defaults.mergedValue;
    };
}
