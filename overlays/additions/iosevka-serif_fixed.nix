{ ... }: final: _prev: {
  iosevka-serif_fixed = final.iosevka.override {
    set = "SerifFixed";
    privateBuildPlan =
      #toml
      ''
        [buildPlans.IosevkaSerifFixed]
        family = "Iosevka Serif Fixed"
        spacing = "fontconfig-mono"
        serifs = "slab"
        noCvSs = true
        exportGlyphNames = false

        [buildPlans.IosevkaSerifFixed.variants.design]
        zero = "dotted"
        a = "double-storey-serifless"
        f = "tailed"
        i = "serifed-flat-tailed"
        l = "tailed-serifed"
        punctuation-dot = "round"

        [buildPlans.IosevkaSerifFixed.weights.Regular]
        shape = 400
        menu = 400
        css = 400

        [buildPlans.IosevkaSerifFixed.weights.Bold]
        shape = 700
        menu = 700
        css = 700

        [buildPlans.IosevkaSerifFixed.slopes.Upright]
        angle = 0
        shape = "upright"
        menu = "upright"
        css = "normal"

        [buildPlans.IosevkaSerifFixed.slopes.Italic]
        angle = 9.4
        shape = "italic"
        menu = "italic"
        css = "italic"
      '';
  };
}
