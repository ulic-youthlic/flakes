{
  makeNixvimWithModule,
  pkgs,
  lib,
  nixvimPlugins,
  neovim_git,
}:
makeNixvimWithModule {
  inherit pkgs;
  extraSpecialArgs = {
    inherit nixvimPlugins;
  };
  module = {
    imports = with lib; youthlic.loadImports' ./. (filter (name: !hasSuffix "/package.nix" (toString name)));
    enableMan = true;
    plugins.lualine.enable = true;
    package = neovim_git;
    performance = {
      # combinePlugins = {
      #   enable = true;
      #   standalonePlugins = [];
      # };
      byteCompileLua = {
        enable = true;
        configs = true;
        initLua = true;
        luaLib = true;
        nvimRuntime = true;
        plugins = true;
      };
    };
    wrapRc = true;
    luaLoader.enable = true;
    extraConfigLua =
      #lua
      ''
        if vim.g.neovide then
        	vim.o.guifont = [[Maple\ Mono\ NF\ CN,Noto Color Emoji:h16]]
        	vim.g.neovide_opacity = 0.9
        	vim.g.linespace = 0.2

        	vim.g.neovide_floating_shadow = true
        	vim.g.neovide_floating_z_height = 10
        	vim.g.neovide_light_angle_degrees = 45
        	vim.g.neovide_light_radius = 5

        	vim.g.neovide_position_animation_length = 0.1
        	vim.g.neovide_scroll_animation_length = 0.2
        	vim.g.neovide_scroll_animation_far_lines = 5
        	vim.g.neovide_hide_mouse_when_typing = true
        	vim.g.neovide_refresh_rate = 120
        	vim.g.neovide_confirm_quit = true
        	vim.g.neovide_input_ime = true

        	vim.g.neovide_cursor_animation_length = 0.1
        	vim.g.neovide_cursor_short_animation_length = 0.04
        	vim.g.neovide_cursor_antialiasing = true
        	vim.g.neovide_cursor_animate_in_insert_mode = true
        	vim.g.neovide_cursor_animate_command_line = true
        	vim.g.neovide_cursor_unfocused_outline_width = 0.125
        end
      '';
  };
}
