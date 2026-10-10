{ inputs, lib, ... }:
{
  den.aspects.zen-browser.xdg-mime =
    let
      browser = lib.mkBefore [ "zen-twilight.desktop" ];
    in
    {
      "text/html" = browser;
      "application/xhtml+xml" = browser;
      "x-scheme-handler/about" = browser;
      "x-scheme-handler/ftp" = browser;
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/unknown" = browser;
    };

  den.aspects.zen-browser.homeManager =
    {
      config,
      pkgs,
      ...
    }:
    {
      # Keyed so a second import into the same home is deduplicated.
      imports = [
        {
          key = "inputs:zen-browser/homeModules.twilight";
          imports = [ inputs.zen-browser.homeModules.twilight ];
        }
      ];
      config = {
        programs.zen-browser = {
          enable = true;
          # The overlay's build instead of the flake's own. The module only
          # applies these two settings to its own build, so pass them here.
          unwrappedPackage = pkgs.zen-browser.twilight-unwrapped.override {
            inherit (config.programs.zen-browser) policies enablePrivateDesktopEntry;
          };
          profiles.default = {
            name = "default";
            isDefault = true;
            extensions = {
              packages = with pkgs.nur.repos.rycee.firefox-addons; [
                redirector
              ];
            };
            search = {
              force = true;
              default = "ddg";
              engines = {
                "Hackage Packages" = {
                  urls = [
                    {
                      template = "https://hackage-content.haskell.org/packages/search";
                      params = [
                        {
                          name = "terms";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  definedAliases = [ "@hp" ];
                };
                "Guix Packages" = {
                  urls = [
                    {
                      template = "https://packages.guix.gnu.org/search/";
                      params = [
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  definedAliases = [ "@gp" ];
                };
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
                  definedAliases = [ "@hm" ];
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
                  definedAliases = [ "@nf" ];
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
                  definedAliases = [ "@nw" ];
                };
                "Rust Stdandard Lib" = {
                  urls = [
                    {
                      template = "https://doc.rust-lang.org/nightly/std/index.html";
                      params = [
                        {
                          name = "search";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  definedAliases = [ "@rs" ];
                };
                "GitHub" = {
                  urls = [
                    {
                      template = "https://github.com/search";
                      params = [
                        {
                          name = "q";
                          value = "{searchTerms}";
                        }
                        {
                          name = "type";
                          value = "repositories";
                        }
                      ];
                    }
                  ];
                  definedAliases = [ "@gh" ];
                };
                "Rust Reference" = {
                  urls = [
                    {
                      template = "https://doc.rust-lang.org/nightly/reference";
                      params = [
                        {
                          name = "search";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  definedAliases = [ "@rr" ];
                };
                "Rust Crates" = {
                  urls = [
                    {
                      template = "https://crates.io/search";
                      params = [
                        {
                          name = "q";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  definedAliases = [ "@rc" ];
                };
                "C++ Reference" = {
                  urls = [
                    {
                      template = "https://duckduckgo.com/";
                      params = [
                        {
                          name = "q";
                          value = "{searchTerms}";
                        }
                        {
                          name = "sites";
                          value = "cppreference.com";
                        }
                      ];
                    }
                  ];
                  definedAliases = [ "@cr" ];
                };
                "bing".metaData.hidden = true;
                "google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
              };
            };
          };
          policies = {
            DisableAppUpdate = true;
            Preferences =
              let
                mkLockedAttrs = builtins.mapAttrs (
                  _: value: {
                    Value = value;
                    Status = "locked";
                  }
                );
              in
              mkLockedAttrs {
                "browser.tabs.closeTabByDblclick" = true;
              };
          };
        };
      };
    };
}
