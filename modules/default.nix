{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: let
  themes = import ../themes {inherit lib;};
  fonts = import ../fonts {inherit pkgs lib;};
  themeNames = builtins.attrNames themes;
  fontNames = builtins.attrNames fonts;
  cfg = config.theme;
in {
  imports = [inputs.stylix.homeModules.stylix];
  options.theme = {
    enable = lib.mkEnableOption "Enable the modular Stylix theme";
    scheme = lib.mkOption {
      type = lib.types.enum themeNames;
      default = "desert-taupe";
      description = "The color scheme to apply.";
    };
    font = lib.mkOption {
      type = lib.types.enum fontNames;
      default = "apple";
      description = "The font family to apply.";
    };
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      base16Scheme = themes.${cfg.scheme};
      fonts = fonts.${cfg.font};

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
      };
    };
  };
}
