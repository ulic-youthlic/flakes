{
  den.aspects.cli-tools.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ripgrep
        fzf
        file
        which
        gnused
        gnutar
        bat
        gawk
        zstd
        tree
        ouch
        dust
        duf
        doggo
        dig
        numbat
        viu
        fd
      ];
    };
}
