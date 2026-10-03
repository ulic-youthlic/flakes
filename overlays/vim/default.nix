{
  den.overlays.vim = { prev }: {
    vim-full = prev.vim-full.customize {
      name = "vim";

      vimrcConfig = {
        customRC = builtins.readFile ./vimrc.vim;
        packages.myVimPackage = {
          start = with prev.vimPlugins; [
            vim-one
            vim-airline
          ];
          opt = [ ];
        };
      };
    };
  };
}
