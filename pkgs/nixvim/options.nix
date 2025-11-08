{...}: {
  globals = {
    mapleader = {
      __raw =
        #lua
        ''
          vim.keycode("<Space>")
        '';
    };
  };
  opts = {
    autoindent = true;
    autoread = true;
    backspace = [
      "indent"
      "eol"
      "start"
    ];
    backup = false;

    breakindent = true;
    breakindentopt = "sbr";
    showbreak = "↪";

    cdhome = true;
    cedit = "<C-F>";
    cmdheight = 1;
    completeopt = [
      "fuzzy"
      "menuone"
      "noselect"
      "popup"
    ];
    concealcursor = "v";
    confirm = true;
    cursorline = true;
    diffopt = [
      "algorithm:minimal"
      "closeoff"
      "context:20"
      "followwrap"
      "internal"
      "linematch:40"
    ];
    errorbells = true;
    expandtab = true;
    exrc = true;
    foldcolumn = "auto";
    fsync = true;
    gdefault = false;
    helplang = [
      "zh"
      "en"
    ];
    history = 10000;
    hlsearch = true;

    ignorecase = true;
    smartcase = true;

    inccommand = "split";
    list = true;
    listchars = "tab:--→,trail:·,multispace: ,nbsp:⍽,space:·"; # eol:⏎
    magic = true;
    more = true;
    mouse = "a";

    number = true;
    numberwidth = 4;
    relativenumber = true;

    scrollback = 100000;
    scrolloff = 5;
    shiftround = true;
    shiftwidth = 2;
    showmode = false;
    signcolumn = "auto";
    smoothscroll = true;
    splitbelow = true;
    splitright = true;
    startofline = true;
    swapfile = false;
    tabclose = "uselast";
    tabstop = 2;
    termguicolors = true;
    undofile = true;
    undolevels = 100000;
    virtualedit = [
      "block"
      "onemore"
    ];
    whichwrap = "b,s,<,>";
    wildmenu = true;
    wildmode = ["full"];
    wildoptions = [
      "fuzzy"
      "pum"
    ];
    winborder = "rounded";
    wrap = true;
  };
}
