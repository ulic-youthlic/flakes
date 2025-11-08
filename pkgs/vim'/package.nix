{
  vim-full,
  vimPlugins,
}:
vim-full.customize {
  name = "vim";

  vimrcConfig = {
    customRC = builtins.readFile ./vimrc.vim;
    packages.myVimPackage = {
      start = with vimPlugins; [
        vim-one
        vim-airline
      ];
      opt = [];
    };
  };
}
