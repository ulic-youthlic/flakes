{ ... }:
{
  youthlic.plugins.lspconfig.enable = true;
  lsp = {
    inlayHints.enable = true;
    luaConfig.post =
      #lua
      ''
        do
          vim.diagnostic.config({
            underline = true,
            virtual_lines = {
              current_line = true,
            },
            signs = true,
            severity_sort = true,
            float = {
              scope = "cursor",
              source = "if_many",
            },
            jump = {
              on_jump = function(diagnostic, bufnr)
                vim.diagnostic.open_float({
                  scope = "cursor",
                  severity_sort = true,
                  source = "if_many",
                  bufnr = bufnr,
                })
              end,
              wrap = true,
            },
          })
        end
      '';
  };
}
