{
  den.aspects.base.system = {
    nixos =
      { lib, ... }:
      {
        programs.gnupg.agent = {
          enable = true;
        };

        environment.variables.EDITOR = "hx";
        services.dbus.implementation = "broker";

        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

        # mkDefault: a host installed from a later release sets its own.
        system.stateVersion = lib.mkDefault "24.11"; # Did you read the comment?
      };
    homeManager =
      { lib, ... }:
      {
        # mkDefault: a user whose home started on a later release sets their own.
        home.stateVersion = lib.mkDefault "24.11";
        programs.home-manager.enable = true;
      };
  };
}
