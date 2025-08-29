{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.david.programs.firefox;
in
{
  options = {
    david.programs.firefox = {
      enable = lib.mkEnableOption "firefox";
    };
  };
  config = lib.mkIf cfg.enable {
    stylix.targets.firefox.profileNames = [
      "default"
    ];
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-beta;
      betterfox = {
        enable = true;
      };
      languagePacks = [
        "zh-CN"
        "en-US"
      ];
      profiles.default = {
        betterfox = {
          enable = true;
          enableAllSections = true;
        };
        name = "default";
        isDefault = true;
        extensions = {
          # settings = {
          #   "redirector@einaregilsson.com" = {
          #     settings = {
          #       redirects = [
          #         {
          #           description = "NixOS Wiki";
          #           exampleUrl = "http://nixos.wiki/wiki/Main_Page";
          #           exampleResult = "http://wiki.nixos.org/wiki/Main_Page";
          #           error = null;
          #           includePattern = "http(s?)://nixos.wiki/wiki/(.*)";
          #           excludePattern = "";
          #           patternDesc = "";
          #           redirectUrl = "http$1://wiki.nixos.org/wiki/$2";
          #           patternType = "R";
          #           processMatches = "noProcessing";
          #           disabled = false;
          #           grouped = false;
          #           appliesTo = [
          #             "main_frame"
          #           ];
          #         }
          #       ];
          #     };
          #   };
          # };
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            immersive-translate
            tridactyl
            redirector
          ];
        };
        settings = {
          "sidebar.verticalTabs" = true;
          "sidebar.visibility" = "expand-on-hover";
          "sidebar.main.tools" = "syncedtabs,history,bookmarks,aichat";
          "sidebar.animation.expand-on-hover.duration-ms" = 150;
          "sidebar.revamp" = true;
          "browser.tabs.closeTabByDblclick" = true;
        };
        search = {
          force = true;
          default = "ddg";
          engines = {
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "Nix Options" = {
              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              definedAliases = [ "@no" ];
            };
            "Home Manager Options" = {
              urls = [
                {
                  template = "https://home-manager-options.extranix.com";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                    {
                      name = "release";
                      value = "master";
                    }
                  ];
                }
              ];
              definedAliases = [ "hm" ];
            };
            "NUR Packages" = {
              urls = [
                {
                  template = "https://nur.nix-community.org/";
                }
              ];
              definedAliases = [ "nu" ];
            };
            "Nix Flakes" = {
              urls = [
                {
                  template = "https://search.nixos.org/flakes";
                  params = [
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              definedAliases = [ "nf" ];
            };
            "NixOS Wiki" = {
              urls = [
                {
                  template = "https://wiki.nixos.org/w/index.php";
                  params = [
                    {
                      name = "search";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              definedAliases = [ "nw" ];
            };
            "bing".metaData.hidden = true;
            "google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
          };
        };
      };
    };
  };
}
