{ inputs, ... }: {
  # The flake's packages (beta, twilight, *-unwrapped), built with our nixpkgs.
  den.overlays.zen-browser = { final }: {
    zen-browser = import inputs.zen-browser { pkgs = final; };
  };
}
