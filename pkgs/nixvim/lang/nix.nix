{
  lib,
  pkgs,
  ...
}:
{
  lsp.servers = {
    nixd = {
      enable = true;
    };
    nil_ls = {
      enable = true;
    };
  };
  youthlic.plugins.conform-nvim.settings = {
    formatters_by_ft.nix = {
      __unkeyed-1 = "alejandra";
      __unkeyed-2 = "injected";
      lsp_format = "fallback";
    };
    formatters = {
      alejandra = {
        __raw =
          #lua
          ''
            function()
                local defaultFormatter = require("conform.formatters.alejandra")
                return vim.tbl_extend("force", defaultFormatter, {
                  command = function()
                    local exe = vim.fn["exepath"]("alejandra")
                    if exe ~= "" then
                      return exe
                    else
                      return "${lib.getExe pkgs.alejandra}"
                    end
                  end
                })
            end
          '';
      };
      nixfmt = {
        __raw =
          #lua
          ''
            function()
                local defaultFormatter = require("conform.formatters.nixfmt")
                return vim.tbl_extend("force", defaultFormatter, {
                  command = function()
                    local exe = vim.fn["exepath"]("nixfmt")
                    if exe ~= "" then
                      return exe
                    else
                      return "${lib.getExe pkgs.nixfmt-rfc-style}"
                    end
                  end
                })
            end
          '';
      };
    };
  };
}
