final: prev:

{
  ghosttyfetch = prev.stdenv.mkDerivation {
    pname = "ghosttyfetch";
    version = "0-unstable-2026-05-06";

    src = prev.fetchFromGitHub {
      owner = "BarutSRB";
      repo = "GhosttyFetch";
      rev = "87552cd0f137013939a2da1bcdc37061ad70b394";
      hash = "sha256-jB1tvSxIuQI5wP4QJTppBa1x9P1Q8j5wfsTTleVI29c=";
    };

    nativeBuildInputs = [
      prev.zig_0_15
    ];

    buildInputs = prev.lib.optionals prev.stdenv.hostPlatform.isDarwin [
      prev.apple-sdk_26
    ];

    postPatch = prev.lib.optionalString prev.stdenv.hostPlatform.isDarwin ''
      substituteInPlace build.zig \
        --replace-fail '        exe.linkFramework("IOKit");' '        exe.linkFramework("IOKit");
            exe.root_module.addFrameworkPath(.{ .cwd_relative = "${prev.apple-sdk_26.sdkroot}/System/Library/Frameworks" });
            exe.root_module.addLibraryPath(.{ .cwd_relative = "${prev.apple-sdk_26.sdkroot}/usr/lib" });'
    '';

    zigBuildFlags = [
      "-Doptimize=ReleaseFast"
    ];

    buildPhase = ''
      runHook preBuild

      zig build --global-cache-dir "$TMPDIR/zig-cache" $zigBuildFlags

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      zig build --global-cache-dir "$TMPDIR/zig-cache" --prefix "$out" $zigBuildFlags install

      ln -s "$out/share/ghosttyfetch/config.json" "$out/bin/config.json"
      ln -s "$out/share/ghosttyfetch/animation.json" "$out/bin/animation.json"

      runHook postInstall
    '';

    meta = {
      description = "Animated system information display tool for Ghostty";
      homepage = "https://github.com/BarutSRB/GhosttyFetch";
      license = prev.lib.licenses.mit;
      maintainers = [ ];
      mainProgram = "ghosttyfetch";
      platforms = prev.lib.platforms.unix;
    };
  };
}
