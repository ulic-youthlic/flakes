{
  lib,
  pkgs,
  ...
}:
{
  youthlic.plugins.conform-nvim.settings = {
    formatters_by_ft.cpp = {
      __unkeyed-1 = "clang-format";
      lsp_format = "fallback";
    };
    formatters.clang-format = {
      __raw =
        #lua
        ''
          function()
            local defaultFormatter = require("conform.formatters.clang-format")
            return vim.tbl_extend("force", defaultFormatter, {
              command = function()
                local exe = vim.fn["exepath"]("clang-format")
                if exe ~= "" then
                  return exe
                else
                  return "${lib.getExe' pkgs.clang-tools "clang-format"}"
                end
              end
            })
          end
        '';
    };
  };
}
