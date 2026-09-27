{
  den.overlays.prismlauncher = { prev }: {
    prismlauncher = prev.prismlauncher.override {
      jdks = with prev; [
        jdk17
        jdk21
        jdk8
        jdk25
      ];
    };
  };
}
