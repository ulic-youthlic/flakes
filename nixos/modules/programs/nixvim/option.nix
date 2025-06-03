{
  lib,
  config,
  ...
}: let
  cfg = config.youthlic.programs.nixvim;
in {
  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      opts = {
        backspace = ["indent" "eol" "start"];
        tabstop = 4;
        shiftwidth = 4;
        expandtab = true;
        shiftround = true;
        autoindent = true;
        nu = true;
        rnu = true;
        wildmenu = true;
        hlsearch = false;
        ignorecase = true;
        smartcase = true;
        completeopt = ["menu" "noselect"];
        cursorline = true;
        termguicolors = true;
        signcolumn = "yes";
        autoread = true;
        title = true;
        swapfile = false;
        backup = false;
        updatetime = 50;
        mouse = "a";
        undofile = true;
        exrc = true;
        scrolloff = 5;
        wrap = true;
        splitright = true;
        splitbelow = true;
      };
    };
  };
}
