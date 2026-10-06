{
  den.aspects.gpg.homeManager =
    {
      pkgs,
      ...
    }:
    {
      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
        pinentry = {
          package = pkgs.pinentry-selector;
        };
        # sshKeys = [
        #   "C817E333BF88F16EA0F7ADE27BDCCC16AD25E5A6"
        # ];
      };
      programs.gpg = {
        enable = true;
        mutableKeys = true;
        mutableTrust = true;
        publicKeys = [
          {
            source = ./public-key.txt;
            trust = "ultimate";
          }
        ];
      };
    };
}
