{...}: {
  userCommands = let
    formatCmd = {
      desc = "Format all the buffer";
      # conform.format function can deal with range by itself
      range = "%";
      bang = true;
      bar = true;
      nargs = "?";
      complete = {
        __raw =
          #lua
          ''
            function(ArgLead, CmdLine, CursorPos)
              return vim.iter(require("conform").list_all_formatters()):filter(function(val)
                return val.available
              end):map(function(val)
                  return val.name
              end):filter(function(name)
                return string.match(name, ArgLead) ~= nil
              end):totable()
            end
          '';
      };
      command = {
        __raw =
          #lua
          ''
            function(opts)
              local format = require("conform").format
              if #(opts.fargs) == 0 then
                return format()
              else
                return format({ formatters = { opts.fargs[1] } })
              end
            end
          '';
      };
    };
  in {
    Format = formatCmd;
    Fmt = formatCmd;
    Formatter = {
      desc = "Show config of formatter";
      nargs = "?";
      bar = true;
      complete = {
        __raw =
          #lua
          ''
            function(ArgLead, CmdLine, CursorPos)
              return vim.iter(require("conform").list_all_formatters()):map(function(val)
                return val.name
              end):filter(function(name)
                return string.match(name, ArgLead) ~= nil
              end):totable()
            end
          '';
      };
      command = {
        __raw =
          #lua
          ''
            function(opts)
              local conform = require("conform")
              if #(opts.fargs) == 0 then
                local formatters = conform.list_all_formatters()
                print(vim.inspect(formatters))
                return formatters
              else
                local config = conform.get_formatter_config(opts.fargs[1])
                print(vim.inspect(config))
                return config
              end
            end
          '';
      };
    };
  };
  keymaps = [
    {
      action = {
        __raw =
          #lua
          ''
            function(opts)
              return require("conform").format()
            end
          '';
      };
      key = "=";
      mode = ["n" "v"];
      options = {
        desc = "Format with conform";
      };
    }
  ];
  plugins.conform-nvim = {
    enable = true;
    settings.formatters.injected.options.ignore_errors = true;
  };
}
