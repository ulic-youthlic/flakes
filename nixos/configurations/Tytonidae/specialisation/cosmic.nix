{ lib, ... }:
{
  config.specialisation.cosmic = {
    inheritParentConfig = true;
    configuration = {
      youthlic.gui.enabled = lib.mkForce "cosmic";
    };
  };
}
