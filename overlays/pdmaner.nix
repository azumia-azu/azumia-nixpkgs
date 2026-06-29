final: prev:

let
  version = "4.9.3";
  electronVersion = "13.1.7";
  electronPlatform = if prev.stdenv.hostPlatform.isDarwin then "darwin" else "linux";
  electronArch = if prev.stdenv.hostPlatform.isAarch64 then "arm64" else "x64";
  electronHash = prev.lib.getAttr "${electronPlatform}-${electronArch}" {
    darwin-arm64 = "sha256-DviR1yLb7o2NoXqXEtMI1/PNzdF5bVQ8wD7lj3obgXo=";
    darwin-x64 = "sha256-EwDWbGtYsyEdxMDc8I2+sYpbFI1IW8q3tNrRm4YK09w=";
    linux-arm64 = "sha256-fjAuAHIR8G3zKfrFeZWo5swruQIDVIZwbSfigQhPPqA=";
    linux-x64 = "sha256-i64TC0zuuNNmT4+nSJ5zCEdBpn8RMWaKtOmNHNIZoKM=";
  };
  electronDist = prev.fetchzip {
    url = "https://github.com/electron/electron/releases/download/v${electronVersion}/electron-v${electronVersion}-${electronPlatform}-${electronArch}.zip";
    hash = electronHash;
    stripRoot = false;
  };
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
      cp -R ${electronDist} electron-dist
      chmod -R u+w electron-dist
      cp ${./pdmaner-package-lock.json} package-lock.json
      substituteInPlace package.json \
        --replace-fail 'electron-builder --mac' 'electron-builder --mac dir' \
        --replace-fail 'electron-builder --linux' 'electron-builder --linux dir' \
        --replace-fail '"asar": true,' '"electronDist": "electron-dist", "asar": true,'
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
