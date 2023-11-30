{pkgs, ...}: {
  packages = with pkgs; [
    rascal
  ];

  languages.java.enable = true;
}
