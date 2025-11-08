{...}: {
  extraConfigLuaPre =
    #lua
    ''
      do
        _M.plugins = {}
        _M.load = function(name)
          _M.plugins = vim.tbl_deep_extend("force", _M.plugins, {
            name = {
              loaded = true,
            },
          })
          vim.schedule(function()
            vim.api.nvim_exec_autocmds("User", { pattern = "LazyLoad", modeline = false, data = name })
          end)
        end
        _M._is_loaded = function(name)
          local plugins = _M.plugins
          return plugins[name] and plugins[name].loaded
        end
        _M.on_load = function(name, fn)
          if _M._is_loaded(name) then
            fn(name)
          else
            vim.api.nvim_create_autocmd("User", {
              pattern = "LazyLoad",
              callback = function(event)
                if event.data == name then
                  fn(name)
                  return true
                end
              end,
            })
          end
        end
      end
    '';
}
