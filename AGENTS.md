# AGENTS.md

## Repo Shape

- This is AzumiA's small personal Nix flake, not an upstream-style `nixpkgs` tree.
- Public packages are exposed in `flake.nix` as `ghosttyfetch`, `pdmaner`, and `toofan`; `default` is `ghosttyfetch`.
- `overlays/default.nix` composes every non-`default.nix` overlay imported by `lib.importNamed`; add `overlays/<name>.nix` and define the matching `<name>` attribute.
- `homeManagerModules` and `nixosModules` come from `lib.importModuleSet`; module files under `modules/home-manager/` and `modules/nixos/` are exported by basename, with a generated `default` module importing all discovered modules.
- `packages/` is not wired into the flake. Do not put package definitions there unless you also change the flake wiring.

## Commands

- Enter the dev shell with `nix develop`; the local `.envrc` contains `use flake` but is ignored by git.
- Format Nix files with `nixfmt`.
- Inspect outputs with `nix flake show`.
- Validate a package with `nix build -L .#<name>`; current package names are `ghosttyfetch`, `pdmaner`, and `toofan`.
- Run `nix flake check -L` before considering broader flake changes complete.
- For module behavior, there are no repo-local module tests; verify from a consumer Home Manager, NixOS, or nix-darwin configuration that imports the relevant module.

## Package And Module Gotchas

- Adding an overlay does not automatically make `.#<name>` buildable; also add the package to `perSystem.packages` in `flake.nix`.
- Keep overlay filename, package attribute, flake package output, and module basename aligned unless there is a deliberate reason not to.
- `ghosttyfetch` is the reference for paired Home Manager and NixOS modules. Both use `programs.ghosttyfetch`, share defaults from `modules/ghosttyfetch/default-settings.nix`, and differ mainly in target path semantics: Home Manager writes under the home directory, NixOS writes under `/etc`.
- `toofan` has Home Manager and NixOS modules that only install the selected package.
- `pdmaner` currently has only a package overlay/output, no Home Manager or NixOS module.
- `overlays/toofan.nix` disables upstream Go checks with `doCheck = false` but enables `versionCheckHook`; preserve that distinction when updating it.
- `overlays/pdmaner.nix` relies on Electron packaging patches and environment variables (`ELECTRON_SKIP_BINARY_DOWNLOAD`, `CSC_IDENTITY_AUTO_DISCOVERY`, `NODE_OPTIONS`). Avoid simplifying them without a successful build.
- `overlays/ghosttyfetch.nix` has Darwin-specific `apple-sdk_26` framework path patching for Zig; validate on Darwin when changing that block.

## Workflow Constraints

- Do not edit `overlays/default.nix`, `modules/home-manager/default.nix`, or `modules/nixos/default.nix` just to register new files; auto-import helpers already do that.
- Do not update `flake.lock` unless the task explicitly requires input changes.
- Do not commit generated/local paths such as `.direnv/` or `result`.
- Update `README.md` when changing user-facing package outputs, overlays, or module options.
