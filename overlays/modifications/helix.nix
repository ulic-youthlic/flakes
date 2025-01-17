{
  outputs,
  ...
}:
final: prev:
let
  inherit (final) stdenv;
  inherit (stdenv.hostPlatform) system;
in
{
  helix = outputs.packages."${system}".helix;
}
