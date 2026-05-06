{ lib, myLib }:

let
  overlays = myLib.importNamed ./.;
in
overlays
// {
  default = lib.composeManyExtensions (builtins.attrValues overlays);
}
