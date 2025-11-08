{...}: {
  youthlic.plugins.lualine = {
    enable = true;
    luaConfig.pre =
      #lua
      ''
        do
          vim.g.lualine_laststatus = vim.o.laststatus
          if vim.fn.argc(-1) > 0 then
            vim.o.statusline = " "
          else
            vim.o.laststatus = 0
          end
        end
        do
          vim.o.laststatus = vim.g.lualine_laststatus
        end
      '';
    settings = {};
  };
}
