{
  pkgs,
  lib,
}: let
  dirContents = builtins.readDir ./.;
  fontFiles = lib.filterAttrs (name: type: name != "default.nix" && type == "regular") dirContents;
in
  lib.mapAttrs' (name: _: lib.nameValuePair (lib.removeSuffix ".nix" name) (import ./${name} {inherit pkgs;})) fontFiles
