{
  lib,
  pkgs,
  ...
}: {
  youthlic.plugins.conform-nvim.settings = {
    formatters_by_ft.python = {
      __unkeyed-1 = "ruff_format";
      __unkeyed-2 = "ruff_organize_imports";
      lsp_format = "fallback";
    };
    formatters = {
      ruff_organize_imports = {
        __raw =
          #lua
          ''
            function()
              local defaultFormatter = require("conform.formatters.ruff_organize_imports")
              return vim.tbl_extend("force", defaultFormatter, {
                command = function()
                  local exe = vim.fn["exepath"]("ruff")
                  if exe ~= "" then
                    return exe
                  else
                    return "${lib.getExe pkgs.ruff}"
                  end
                end
              })
            end
          '';
      };
      ruff_format = {
        __raw =
          #lua
          ''
            function()
              local defaultFormatter = require("conform.formatters.ruff_format")
              return vim.tbl_extend("force", defaultFormatter, {
                command = function()
                  local exe = vim.fn["exepath"]("ruff")
                  if exe ~= "" then
                    return exe
                  else
                    return "${lib.getExe pkgs.ruff}"
                  end
                end
              })
            end
          '';
      };
    };
  };
}
