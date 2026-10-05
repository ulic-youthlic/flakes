{ inputs, ... }:
{
  # Hosts declare their own disk layouts; this only provides the options.
  den.aspects.disko.nixos.imports = [ inputs.disko.nixosModules.disko ];
}
