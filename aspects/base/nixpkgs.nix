{ self, ... }:
{
  den.aspects.base.nixpkgs.nixos =
    { lib, ... }:
    {
      nixpkgs = {
        overlays = [ self.overlays.default ];
        config = {
          allowUnfree = true;
          allowInsecurePredicate =
            p:
            builtins.elem (lib.getName p) [
              "electron"

              "radicle-node"
            ];
          packageOverrides = p: {
            intel-vaapi-driver = p.intel-vaapi-driver.override { enableHybridCodec = true; };
          };
        };
      };
    };
}
