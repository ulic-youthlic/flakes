{ pkgs, ... }:
{
  users.users.david = {
    isNormalUser = true;
    description = "david";
    extraGroups = [
      "networkmanager"
      "libvirtd"
      "wheel"
    ];
  };
  programs.fish.enable = true;
  users.users.david.shell = pkgs.fish;
  users.users.david.openssh.authorizedKeys.keyFiles = [
    ./tytonidae.pub
  ];
}
