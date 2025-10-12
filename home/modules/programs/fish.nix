{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.youthlic.programs.fish;
in
{
  options = {
    youthlic.programs.fish = {
      enable = lib.mkEnableOption "fish";
    };
  };
  config = lib.mkIf cfg.enable {
    programs = {
      fish = {
        enable = true;
        preferAbbrs = true;
        interactiveShellInit = ''
          fish_vi_key_bindings
        '';
        plugins = [
          {
            name = with pkgs.fishPlugins.foreign-env; pname + "-" + version;
            src = pkgs.fishPlugins.foreign-env.overrideAttrs {
              postInstall = # bash
                ''
                  ln -s $out/share/fish/vendor_functions.d $out/functions
                '';
            };
          }
        ];
        functions = {
          __fish_command_not_found_handler = {
            body = "__fish_default_command_not_found_handler $argv[1]";
            onEvent = "fish_command_not_found";
          };
          fish_greeting = {
            body = '''';
          };
        };
        shellInitLast = # fish
          ''
            if test -d ~/.guix-profile
              set -gx GUIX_PROFILE ~/.guix-profile
              if test -f $GUIX_PROFILE/etc/profile
                fenv source $GUIX_PROFILE/etc/profile
              end
              if test -d $GUIX_PROFILE/lib/locale
                set -gx GUIX_LOCPATH $GUIX_PROFILE/lib/locale
              end
            end
          '';
      };
      fastfetch.enable = true;
    };
  };
}
