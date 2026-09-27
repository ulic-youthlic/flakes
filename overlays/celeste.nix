{
  den.overlays.celestegame = { prev }: {
    celestegame = prev.celestegame.override {
      withEverest = true;
      writableDir = "/home/david/.local/share/Everest";
      gameDir = "/home/david/.local/share/Celeste-Olympus";
    };
  };
}
