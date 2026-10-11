{
  pkgs,
  ...
}:
{

  time.timeZone = "America/New_York";

  # A headless server: no documentation, and no command-not-found, which
  # only works with a channel anyway.
  documentation.enable = false;
  programs.command-not-found.enable = false;

  programs.vim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.vim-plain;
  };

  environment.systemPackages = with pkgs; [
    nix-output-monitor
    wget
    git
    btop
  ];

  boot.loader.grub = {
    enable = true;
  };
  nix = {
    settings = {
      system-features = [ "gccarch-ivybridge" ];
    };
  };

}
