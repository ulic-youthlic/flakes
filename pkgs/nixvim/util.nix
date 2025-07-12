{
  pkgs,
  nixvimPlugins,
  ...
}: {
  extraPlugins = [
    {
      config =
        #vim
        ''
        '';
      plugin = nixvimPlugins.vim-startuptime;
    }
  ];
}
