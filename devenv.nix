{pkgs, ...}: {
  packages = with pkgs; [
    jdk17
  ];

  languages.java.enable = true;
}
