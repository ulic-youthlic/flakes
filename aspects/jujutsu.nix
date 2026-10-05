{ den, lib, ... }:
{
  den.aspects.jujutsu =
    { user, ... }:
    let
      identity = user.identity;
      signingKey = identity.signingKey or null;
    in
    {
      includes = lib.optional (signingKey != null) den.aspects.gpg;
      homeManager =
        { pkgs, ... }:
        {
          config = lib.mkMerge [
            {
              home.packages = [
                pkgs.watchman
              ];
              programs.jujutsu = {
                enable = true;
                settings = {
                  "$schema" = "https://jj-vcs.github.io/jj/latest/config-schema.json";
                  user = { inherit (identity) name email; };
                  aliases = {
                    dlog = [
                      "log"
                      "-r"
                    ];
                    l = [
                      "log"
                      "-r"
                      "(trunk()..@):: | (trunk()..@)-"
                    ];
                    fresh = [
                      "new"
                      "trunk()"
                    ];
                    tug = [
                      "bookmark"
                      "move"
                      "--from"
                      "closest_bookmark(@)"
                      "--to"
                      "closest_pushable(@)"
                    ];
                  };
                  snapshot = {
                    auto-track = "true";
                    max-new-file-size = 0;
                  };
                  fsmonitor = {
                    backend = "watchman";
                    watchman.register-snapshot-trigger = true;
                  };
                  ui = {
                    color = "auto";
                    movement.edit = true;
                    graph.style = "curved";
                    show-cryptographic-signatures = true;
                    pager = "delta";
                    diff-editor = ":builtin";
                    diff = {
                      color-words = {
                        conflict = "pair";
                      };
                    };
                    default-command = "l";
                  };
                  templates = {
                    log = ''
                      builtin_log_compact_full_description
                    '';
                  };
                  template-aliases = {
                    "format_short_signature(signature)" = "signature";
                  };
                  revset-aliases = {
                    "closest_bookmark(to)" = "heads(::to & bookmarks())";
                    "closest_pushable(to)" =
                      "heads(::to & mutable() & ~description(exact:\"\") & (~empty() | merges()))";
                    "desc(x)" = "description(x)";
                    "pending()" = ".. ~ ::tags() ~ ::remote_bookmarks() ~ @ ~ private()";
                    "private()" = ''
                      description(glob:'wip:*') |
                      description(glob:'private:*') |
                      description(glob:'WIP:*') |
                      description(glob:'PRIVATE:*') |
                      conflicts() |
                      (empty() ~ merges()) |
                      description(substring-i:"DO NOT NAIL")
                    '';
                  };
                  git = {
                    abandon-unreachable-commits = false;
                  };
                };
              };
            }
            (lib.mkIf (signingKey != null) {
              programs.jujutsu.settings = {
                git.sign-on-push = true;
                signing = {
                  key = signingKey;
                  behavior = "drop";
                  backend = "gpg";
                };
              };
            })
          ];
        };
    };
}
