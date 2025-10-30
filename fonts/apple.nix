{pkgs}: {
  serif = {
    package = pkgs.apple-fonts;
    name = "New York";
  };
  sansSerif = {
    package = pkgs.apple-fonts;
    name = "SF Pro Display";
  };
  monospace = {
    package = pkgs.apple-fonts;
    name = "SF Mono";
  };
  emoji = {
    package = pkgs.noto-fonts-color-emoji;
    name = "Noto Color Emoji";
  };
}
