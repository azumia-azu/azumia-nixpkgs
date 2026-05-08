final: prev:

let
  electron = prev.electron;
in
{
  pdmaas = prev.buildNpmPackage {
    pname = "pdmaas";
    version = "2.1.6-unstable-2025-09-07";

    src = prev.fetchFromGitHub {
      owner = "yonsum";
      repo = "PDMaas";
      rev = "876a3f5e556a53e06ea3f9693e6914e1af55a364";
      hash = "sha256-idN/gOGQSp6E0PtGODiVH1JpYonoNQqeB1NkGmxkW4c=";
    };

    npmDepsHash = "sha256-k9C9iAgy7AZrCWcE0QYEJrk1IjAOX6n9BKcQz8llgm0=";
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
      substituteInPlace package.json \
        --replace-fail 'electron-builder --mac' 'electron-builder --mac dir' \
        --replace-fail 'electron-builder --linux' 'electron-builder --linux dir'
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/pdmaas" "$out/bin"
      cp app/package.json "$out/share/pdmaas/package.json"
      cp -R app/build "$out/share/pdmaas/build"

      if [ -d dist ]; then
        cp -R dist "$out/share/pdmaas/dist"
      fi

      mkdir -p "$out/share/pdmaas/node_modules/@electron"
      cp -R node_modules/@electron/remote "$out/share/pdmaas/node_modules/@electron/remote"

      makeWrapper ${electron}/bin/electron "$out/bin/pdmaas" \
        --add-flags "$out/share/pdmaas"

      runHook postInstall
    '';

    meta = {
      description = "Open-source data modeling platform desktop application";
      homepage = "https://github.com/yonsum/PDMaas";
      license = prev.lib.licenses.agpl3Only;
      maintainers = [ ];
      mainProgram = "pdmaas";
      platforms = electron.meta.platforms;
    };
  };
}
