{ ... }:
{
  youthlic.plugins.blink-cmp = {
    enable = true;
    setupLspCapabilities = true;
    settings = {
      snippets = {
        expand = {
          __raw =
            #lua
            ''
              function(snippet, _)
                return {}
              end
            '';
        };
      };
      appearance = {
        # use_nvim_cmp_as_default = false;
      };
      completion = {
        accept = {
          auto_brackets = {
            enabled = true;
          };
        };
        menu = {
          draw = {
            treesitter = [ "lsp" ];
          };
        };
        documentation = {
          auto_show = true;
          auto_show_delay_ms = 200;
        };
        ghost_text = {
          enabled = {
            __raw =
              #lua
              ''vim.g.ai_cmp'';
          };
        };
      };
      sources = {
        compat = [ ];
        default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
      };
      cmdline = {
        enabled = false;
      };
      keymap = {
        preset = "enter";
      };
    };
  };
}
