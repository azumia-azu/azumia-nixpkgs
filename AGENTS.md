# AGENTS.md

Guidance for AI agents working in this repository.

## Project Overview

This is AzumiA's personal nixpkgs-like package source. It is a small Nix flake, not a full upstream `nixpkgs` tree.

The repository currently provides:

- flake package outputs, with `ghosttyfetch` as the default package
- overlays exported through `overlays.default`
- Home Manager modules exported through `homeManagerModules`
- NixOS modules exported through `nixosModules`
- shared helper functions under `lib/`

## Repository Structure

- `flake.nix`: primary flake entrypoint. Uses `flake-parts`, imports `nixpkgs`, wires overlays, packages, modules, `lib`, and the development shell.
- `flake.lock`: pinned flake inputs.
- `lib/default.nix`: helper import functions. `importNamed` auto-imports sibling `.nix` files and module directories; `importModuleSet` builds named module outputs plus a `default` module importing all discovered modules.
- `overlays/`: overlay files. Each non-`default.nix` file is auto-imported and composed into `overlays.default`.
- `modules/home-manager/`: Home Manager modules. Files are auto-exported by basename through `homeManagerModules`.
- `modules/nixos/`: NixOS modules. Files are auto-exported by basename through `nixosModules`.
- `modules/<feature>/`: shared data used by feature modules, for example `modules/ghosttyfetch/default-settings.nix`.
- `packages/`: currently empty and not wired into `flake.nix`; do not assume package files placed here are discovered automatically.
- `README.md`: consumer-facing usage documentation.

Generated/local directories such as `.direnv/` and `result/` should not be committed.

## Development Environment

Use the flake development shell. `.envrc` contains `use flake`, and the dev shell currently includes tools such as `git`, `nil`, `nixfmt`, `nix-output-monitor`, and `zig_0_15`.

Useful commands:

```sh
nix develop
nix flake show
nix flake check -L
nix build -L .#ghosttyfetch
```

For package-specific work, validate the package with `nix build -L .#<name>`. For module work, also validate from a consumer Home Manager, NixOS, or nix-darwin flake where the module is enabled.

## Formatting

- Format Nix files with `nixfmt`.
- Keep Nix code idiomatic and close to the existing style: two-space indentation, small `let` bindings, explicit option definitions, and simple attrsets.
- Prefer ASCII unless an existing file or user-facing text already uses non-ASCII content.

## Adding A New Package Or Module

Use the existing `ghosttyfetch` implementation as the reference pattern.

### 1. Add The Overlay Package

Create `overlays/<name>.nix` and define the package attribute with the same `<name>`.

Example shape:

```nix
final: prev:

{
  <name> = prev.stdenv.mkDerivation {
    pname = "<name>";
    version = "...";
    # ...
  };
}
```

Important conventions:

- File basename and package attribute should match: `overlays/foo.nix` should define `foo`.
- Do not edit `overlays/default.nix` just to register the new overlay. It already uses `myLib.importNamed ./.` and composes all discovered overlay files.
- Do not place a package under `packages/` unless you also wire that directory into the flake; it is currently unused.

### 2. Expose The Flake Package Output

If the package should be directly buildable as `.#<name>`, add it to `perSystem.packages` in `flake.nix`.

Current pattern:

```nix
packages = {
  default = pkgs.ghosttyfetch;

  inherit (pkgs)
    ghosttyfetch
    ;
};
```

Add the new package to the `inherit (pkgs)` list. Update `default` only if the default package should change.

### 3. Add Home Manager Or NixOS Modules

Create one or both of these files when the feature needs module support:

- `modules/home-manager/<name>.nix`
- `modules/nixos/<name>.nix`

The module filename becomes the exported flake key:

- `modules/home-manager/foo.nix` becomes `homeManagerModules.foo`
- `modules/nixos/foo.nix` becomes `nixosModules.foo`

Do not manually register the module in `modules/home-manager/default.nix` or `modules/nixos/default.nix`; both use `myLib.importModuleSet ./.`.

For feature defaults or shared config data, use `modules/<name>/...` and import those files from both module variants when appropriate.

### 4. Keep Module Options Consistent

When adding both Home Manager and NixOS modules for the same feature, keep option names and behavior aligned where possible. The existing `ghosttyfetch` modules use the same `programs.ghosttyfetch` namespace and share options such as:

- `enable`
- `package`
- `settings`
- `animation`

Target paths can differ by module type when needed. For example, Home Manager writes relative to the home directory, while the NixOS module writes under `/etc`.

### 5. Update Documentation

Update `README.md` when adding user-facing outputs. Include minimal examples for:

- adding this flake as an input
- using `inputs.azumia-nixpkgs.overlays.default`
- importing `homeManagerModules.<name>` or `nixosModules.<name>`
- enabling the module and setting key options

## Validation Checklist

Before considering work complete, run the narrowest useful checks first, then widen as needed.

For package changes:

```sh
nix flake show
nix build -L .#<name>
nix flake check -L
```

For overlay-only changes, confirm that `nix flake show` exposes the expected package output if it should be public.

For module changes:

```sh
nix flake show
nix flake check -L
```

Then evaluate or switch a consumer configuration that imports the module. There are no dedicated module tests in this repository yet, so consumer-flake validation is the practical integration check.

## Do Not

- Do not bypass `importNamed` or `importModuleSet` with ad hoc manual registries unless the repository structure is intentionally being changed.
- Do not mismatch overlay filenames, package attributes, module filenames, and flake output names.
- Do not assume `packages/` is active; it is currently empty and unwired.
- Do not commit build outputs, `result` symlinks, `.direnv/`, or other local artifacts.
- Do not update `flake.lock` unless the task explicitly requires changing inputs.
- Do not make broad unrelated refactors while adding a package or module.

## Quick Reference

Adding a public package named `foo` usually means:

1. Add `overlays/foo.nix` defining `foo`.
2. Add `foo` to `perSystem.packages` in `flake.nix`.
3. Run `nix build -L .#foo`.
4. Update `README.md` if users should consume it.

Adding a module named `foo` usually means:

1. Add `modules/home-manager/foo.nix` and/or `modules/nixos/foo.nix`.
2. Add shared defaults under `modules/foo/` if needed.
3. Run `nix flake show` and `nix flake check -L`.
4. Validate from a consumer configuration that imports `homeManagerModules.foo` or `nixosModules.foo`.
5. Update `README.md` with usage examples.
