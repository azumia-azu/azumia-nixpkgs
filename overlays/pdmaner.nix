final: prev:

let
  version = "4.9.3";
in
{
  pdmaner = prev.buildNpmPackage {
    pname = "pdmaner";
    inherit version;

    src = prev.fetchzip {
      url = "https://gitee.com/robergroup/pdmaner/repository/archive/v${version}.tar.gz";
      hash = "sha256-MsIKXREFvIny+RTCPdcmD/riF7em2whJwtfxw52+BTs=";
    };

    npmDepsHash = "sha256-HnAWKq2iy5a2U1xilYxzrgmFN7VnWQNGGM5tZ2CNheY=";
    npmDepsFetcherVersion = 2;

    nativeBuildInputs = [
      prev.makeWrapper
    ];

    npmFlags = [
      "--legacy-peer-deps"
      "--ignore-scripts"
    ];

    npmBuildScript = if prev.stdenv.hostPlatform.isDarwin then "package-mac" else "package-linux";

    env = {
      CSC_IDENTITY_AUTO_DISCOVERY = "false";
      ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
      NODE_OPTIONS = "--openssl-legacy-provider";
    };

    postPatch = ''
      mkdir -p jre/linux
      cp ${./pdmaner-package-lock.json} package-lock.json
      substituteInPlace package.json \
        --replace-fail 'electron-builder --mac' 'electron-builder --mac dir' \
        --replace-fail 'electron-builder --linux' 'electron-builder --linux dir'
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/pdmaner" "$out/bin"
      cp app/package.json "$out/share/pdmaner/package.json"
      cp -R app/build "$out/share/pdmaner/build"

      if [ -d dist/mac-arm64 ]; then
        mkdir -p "$out/Applications"
        cp -R dist/mac-arm64/PDManer.app "$out/Applications/PDManer.app"
        makeWrapper "$out/Applications/PDManer.app/Contents/MacOS/PDManer" "$out/bin/pdmaner"
      elif [ -d dist/mac ]; then
        mkdir -p "$out/Applications"
        cp -R dist/mac/PDManer.app "$out/Applications/PDManer.app"
        makeWrapper "$out/Applications/PDManer.app/Contents/MacOS/PDManer" "$out/bin/pdmaner"
      else
        cp -R dist "$out/share/pdmaner/dist"
        makeWrapper "$out/share/pdmaner/dist/linux-unpacked/PDManer" "$out/bin/pdmaner"
      fi

      runHook postInstall
    '';

    meta = {
      description = "Open-source data modeling platform desktop application";
      homepage = "https://gitee.com/robergroup/pdmaner";
      license = prev.lib.licenses.agpl3Only;
      maintainers = [ ];
      mainProgram = "pdmaner";
      platforms = prev.lib.platforms.linux ++ prev.lib.platforms.darwin;
    };
  };
}
