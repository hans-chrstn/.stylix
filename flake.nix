{
  description = "A modular and automated Stylix theming flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    stylix,
  } @ inputs: let
    lib = nixpkgs.lib;
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    forAllSystems = f: lib.genAttrs systems f;
  in {
    homeModules.default = import ./modules;
    overlays.default = final: prev:
      (import ./packages) {
        pkgs = final;
        lib = prev.lib;
      };

    apps = forAllSystems (system: {
      new-theme = {
        type = "app";
        program = "${self}/scripts/new-theme.sh";
      };
      new-font = {
        type = "app";
        program = "${self}/scripts/new-font.sh";
      };
    });
  };
}
