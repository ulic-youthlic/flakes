{ ... }:
{
  youthlic.plugins.snacks = {
    enable = true;
    luaConfig.content =
      #lua
      ''
        -- Terminal Mappings
        _M.__util_plugin_snacks_term_nav = function(direction)
          ---@param self snacks.terminal
          return function(self)
            return self:is_floating() and "<c-" .. direction .. ">"
              or vim.schedule(function()
                vim.cmd.wincmd(direction)
              end)
          end
        end
      '';
    settings = {
      bigfile = {
        enabled = true;
      };
      quickfile = {
        enabled = true;
      };
      terminal = {
        win = {
          keys = {
            nav_h = {
              __unkeyed-1 = "<C-w>h";
              __unkeyed-2 = {
                __raw =
                  #lua
                  ''
                    _M.__util_plugin_snacks_term_nav("h")
                  '';
              };
              desc = "Go to Left Window";
              expr = true;
              mode = "t";
            };
            nav_j = {
              __unkeyed-1 = "<C-w>j";
              __unkeyed-2 = {
                __raw =
                  #lua
                  ''
                    _M.__util_plugin_snacks_term_nav("j")
                  '';
              };
              desc = "Go to Lower Window";
              expr = true;
              mode = "t";
            };
            nav_k = {
              __unkeyed-1 = "<C-w>k";
              __unkeyed-2 = {
                __raw =
                  #lua
                  ''
                    _M.__util_plugin_snacks_term_nav("k")
                  '';
              };
              desc = "Go to Upper Window";
              expr = true;
              mode = "t";
            };
            nav_l = {
              __unkeyed-1 = "<C-w>l";
              __unkeyed-2 = {
                __raw =
                  #lua
                  ''
                    _M.__util_plugin_snacks_term_nav("l")
                  '';
              };
              desc = "Go to Right Window";
              expr = true;
              mode = "t";
            };
          };
        };
      };
    };
  };
}
