{
  # nixpkgs' perlless profile without its check
  # (system.forbiddenDependenciesRegexes): /etc becomes an overlay and
  # userborn manages users, so activation no longer runs setup-etc.pl and
  # update-users-groups.pl. Desktop apps still pull perl into the closure
  # (xdg-utils, aspell, steam, ...).
  den.aspects.perlless.nixos =
    { pkgs, ... }:
    {
      system.etc.overlay.enable = true;
      # The first switch mounts the overlay over the old /etc with an empty
      # upper layer, hiding the state kept there (shadow, SSH host keys,
      # machine-id, ...). Refuse it until that state is copied to
      # /.rw-etc/upper.
      system.preSwitchChecks.etcOverlayUpper = ''
        if [ "$2" != dry-activate ] && ! ${pkgs.util-linux}/bin/mountpoint -q /etc && [ ! -e /.rw-etc/upper/shadow ]; then
          echo "/etc is not an overlay yet: copy its state to /.rw-etc/upper first" >&2
          exit 1
        fi
      '';
      services.userborn.enable = true;
      system.tools.nixos-generate-config.enable = false;
      programs.command-not-found.enable = false;
      # The default list without perl.
      environment.defaultPackages = builtins.attrValues {
        inherit (pkgs)
          rsync
          strace
          ;
      };
    };
}
