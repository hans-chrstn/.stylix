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
      description =
        "The color scheme to apply. Available schemes: "
        + lib.concatStringsSep " | " themeNames;
    };

    font = lib.mkOption {
      type = lib.types.enum fontNames;
      default = "apple";
      description =
        "The font family to apply. Available fonts: "
        + lib.concatStringsSep " | " fontNames;
    };

    image = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Wallpaper image to use and generate a scheme from.";
    };

    polarity = lib.mkOption {
      type = lib.types.enum ["either" "light" "dark"];
      default = "either";
      description = "Force a light or dark theme.";
    };

    cursor = lib.mkOption {
      type = lib.types.submodule {
        options = {
          package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.bibata-cursors;
            description = "Package providing the cursor theme.";
          };
          name = lib.mkOption {
            type = lib.types.str;
            default = "Bibata-Modern-Ice";
            description = "The cursor name within the package.";
          };
          size = lib.mkOption {
            type = lib.types.int;
            default = 24;
            description = "The cursor size.";
          };
        };
      };
      default = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
      };
      description = "System-wide cursor theme.";
    };

    opacity = lib.mkOption {
      type = lib.types.submodule {
        options = {
          applications = lib.mkOption {
            type = lib.types.float;
            default = 1.0;
          };
          desktop = lib.mkOption {
            type = lib.types.float;
            default = 1.0;
          };
          popups = lib.mkOption {
            type = lib.types.float;
            default = 1.0;
          };
          terminal = lib.mkOption {
            type = lib.types.float;
            default = 1.0;
          };
        };
      };
      default = {
        applications = 1.0;
        desktop = 1.0;
        popups = 1.0;
        terminal = 1.0;
      };
      description = "Opacity levels for different window types.";
    };
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = true;
      base16Scheme = themes.${cfg.scheme};
      targets.zen-browser.profileNames = ["default"];
      fonts = fonts.${cfg.font};
      image = cfg.image;
      polarity = cfg.polarity;
      cursor = cfg.cursor;
      opacity = cfg.opacity;
    };
  };
}
