{...}: {
  youthlic.plugins.bufferline = {
    enable = true;
    settings = {
      options = {
        close_command = {
          __raw =
            #lua
            ''
              function(n)
                Snacks.bufdelete(n)
              end
            '';
        };
        right_mouse_command = {
          __raw =
            #lua
            ''
              function(n)
                Snacks.bufdelete(n)
              end
            '';
        };
        diagnostics = "nvim_lsp";
        always_show_bufferline = false;
        diagnostics_indicator = {
          __raw =
            #lua
            ''
              function(_, _, diag)
                local icons = {
                  Error = " ",
                  Warn = " ",
                  Hint = " ",
                  Info = " ",
                }
                local ret = (diag.error and icons.Error .. diag.error .. " " or "")
                  .. (diag.warning and icons.Warn .. diag.warning or "")
                return vim.trim(ret)
              end
            '';
        };
        offsets = [
          {
            filetype = "neo-tree";
            text = "Neo-tree";
            highlight = "Directory";
            text_align = "left";
          }
          {
            filetype = "snacks_layout_box";
          }
        ];
        get_element_icon = {
          __raw =
            #lua
            ''
              function(opts)
                local icons = {
                  octo = "",
                }
                return icons[opts.filetype]
              end
            '';
        };
      };
    };
  };
}
