{lib, ...}: {
  config.specialisation.kde = {
    inheritParentConfig = true;
    configuration = {
      youthlic.gui.enabled = lib.mkForce "kde";
    };
  };
}
