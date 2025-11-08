{nixvimPlugins, ...}: {
  extraPlugins = [
    {
      config =
        #vim
        ''
          lua << EOF
          EOF
        '';
      plugin = nixvimPlugins.vim-startuptime;
    }
  ];
}
