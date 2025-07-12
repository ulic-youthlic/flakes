{
  lib,
  pkgs,
  ...
}: {
  plugins.conform-nvim.settings = {
    formatters_by_ft.toml = {
      __unkeyed-1 = "taplo";
      lsp_format = "fallback";
    };
    formatters.taplo = {
      __raw =
        #lua
        ''
          function()
            local defaultFormatter = require("conform.formatters.taplo")
            return vim.tbl_extend("force", defaultFormatter, {
              command = function()
                local exe = vim.fn["exepath"]("taplo")
                if exe ~= "" then
                  return exe
                else
                  return "${lib.getExe pkgs.taplo}"
                end
              end,
              args = { "format", "-o", "reorder_keys=true", "-o", "reorder_inline_tables=true", "-o", "reorder_arrays=true", "-" },
            })
          end
        '';
    };
  };
}
