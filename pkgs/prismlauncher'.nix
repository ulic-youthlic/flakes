{
  prismlauncher,
  jdk17,
  jdk21,
  jdk8,
  jdk25,
}:
prismlauncher.override {
  jdks = [
    jdk17
    jdk21
    jdk8
    jdk25
  ];
}
