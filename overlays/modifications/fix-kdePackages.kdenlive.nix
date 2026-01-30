{...}: final: prev: {
  kdePackages =
    prev.kdePackages
    // {
      kdenlive = prev.kdePackages.kdenlive.override {
        ffmpeg-full = final.ffmpeg_7-full;
      };
    };
}
