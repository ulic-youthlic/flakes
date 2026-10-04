{ inputs, ... }:
{
  # Extra libraries every flake module receives as arguments, so aspects
  # do not reach into flake inputs. Not usable in `imports`, like any
  # argument set through _module.args.
  _module.args = {
    # nix-kdl: write KDL documents (niri, noctalia) from Nix.
    kdl = inputs.nix-kdl.kdl;
  };
}
