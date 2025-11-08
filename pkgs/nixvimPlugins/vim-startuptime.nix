{
  srcs,
  vimUtils,
}: let
  inherit (srcs.nvim_vim-startuptime) src version date;
in
  vimUtils.buildVimPlugin {
    pname = "vim-startuptime";
    version = "0-unstable-${date}-git${version}";
    inherit src;
  }
