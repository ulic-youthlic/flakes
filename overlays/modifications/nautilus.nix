{ ... }: _final: prev: {
  nautilus = prev.nautilus.overrideAttrs (nprev: {
    buildInputs =
      (nprev.buildInputs or [ ])
      ++ (with prev.gst_all_1; [
        gst-plugins-good
        gst-plugins-bad
      ]);
  });
}
