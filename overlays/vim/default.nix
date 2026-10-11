{
  den.overlays.vim =
    { prev }:
    let
      customization = {
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
    in
    {
      vim-full = prev.vim-full.customize customization;
      # Without the GUI and the Lua, Python and Ruby interfaces, for servers.
      vim-plain = prev.vim.customize customization;
    };
}
