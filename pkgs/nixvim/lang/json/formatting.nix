{
  lib,
  pkgs,
  ...
}: {
  plugins.conform-nvim.settings = {
    formatters_by_ft.json = {
      __unkeyed-1 = "deno_fmt";
    };
    formatters.deno_fmt = {
      __raw =
        #lua
        ''
          function()
            local defaultFormatter = require("conform.formatters.deno_fmt")
            return vim.tbl_extend("force", defaultFormatter, {
              command = function()
                local exe = vim.fn["exepath"]("deno")
                if exe ~= "" then
                  return exe
                else
                  return "${lib.getExe pkgs.deno}"
                end
              end
            })
          end
        '';
    };
  };
}
