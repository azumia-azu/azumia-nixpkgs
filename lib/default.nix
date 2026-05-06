{ lib }:

rec {
  importNamed =
    dir:
    let
      entries = builtins.readDir dir;

      nixFileNames = lib.filter (
        name: entries.${name} == "regular" && name != "default.nix" && lib.hasSuffix ".nix" name
      ) (builtins.attrNames entries);

      directoryNames = lib.filter (
        name: entries.${name} == "directory" && builtins.pathExists (dir + "/${name}/default.nix")
      ) (builtins.attrNames entries);

      fileImports = lib.genAttrs nixFileNames (name: import (dir + "/${name}"));

      directoryImports = lib.genAttrs directoryNames (name: import (dir + "/${name}"));
    in
    lib.mapAttrs' (name: value: lib.nameValuePair (lib.removeSuffix ".nix" name) value) fileImports
    // directoryImports;

  importModuleSet =
    dir:
    let
      modules = importNamed dir;
    in
    modules
    // {
      default = {
        imports = builtins.attrValues modules;
      };
    };
}
