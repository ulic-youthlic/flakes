{ inputs, ... }:
let
  # Extra libraries every NixOS and home-manager module receives as
  # arguments, so modules do not reach into flake inputs. Not usable in
  # `imports`, like any argument set through _module.args.
  args = {
    # nix-kdl: write KDL documents (niri, noctalia) from Nix.
    kdl = inputs.nix-kdl.kdl;
  };
in
{
  den.aspects.base.args = {
    nixos._module = { inherit args; };
    homeManager._module = { inherit args; };
  };
}
