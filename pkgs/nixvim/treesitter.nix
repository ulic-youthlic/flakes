{ ... }:
{
  youthlic.plugins = {
    treesitter = {
      enable = true;
      # folding = true;
      nixvimInjections = true;
      settings = {
        highlight = {
          enable = true;
          additional_vim_regex_highlighting = true;
        };
        indent.enable = true;
      };
    };
  };
}
