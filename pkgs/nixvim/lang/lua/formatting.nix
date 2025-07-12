{
  lib,
  pkgs,
  ...
}: {
  plugins.conform-nvim.settings = {
    formatters_by_ft.lua = {
      __unkeyed-1 = "stylua";
      lsp_format = "fallback";
    };
    formatters.stylua = {
      __raw =
        #lua
        ''
          function()
              local defaultFormatter = require("conform.formatters.stylua")
              return vim.tbl_extend("force", defaultFormatter, {
                command = function()
                  local exe = vim.fn["exepath"]("stylua")
                  if exe ~= "" then
                    return exe
                  else
                    return "${lib.getExe pkgs.stylua}"
                  end
                end
              })
          end
        '';
    };
  };
}
