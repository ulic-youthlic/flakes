{
  den.aspects.desktop.ly.nixos.services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "dur_file";
      dur_file_path = "${./blackhole-smooth-240x67.dur}";
      full_color = true;
      animation_frame_delay = 5;
      animation_timeout_sec = 0;
      # Ly's compiled-in default is "ly-session.log" (relative to $HOME),
      # unlike the ".local/state/ly-session.log" in its sample config.ini.
      session_log = ".local/state/ly-session.log";
    };
  };
}
