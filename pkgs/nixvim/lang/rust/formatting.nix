{
  lib,
  pkgs,
  ...
}: {
  plugins.conform-nvim.settings = {
    formatters_by_ft.rust = {
      __unkeyed-1 = "rustfmt";
      lsp_format = "fallback";
    };
    formatters.rustfmt = {
      __raw =
        #lua
        ''
          function()
            local defaultFormatter = require("conform.formatters.rustfmt")
            return vim.tbl_extend("force", defaultFormatter, {
              command = function()
                local exe = vim.fn["exepath"]("rustfmt")
                if exe ~= "" then
                  return exe
                else
                  return "${lib.getExe pkgs.rustfmt}"
                end
              end
            })
          end
        '';
    };
  };
}
