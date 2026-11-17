final: prev:

let
  version = "0.10.0";
in
{
  sqlmux = prev.buildGoModule {
    pname = "sqlmux";
    inherit version;

    src = prev.fetchFromGitHub {
      owner = "kackerx";
      repo = "sqlmux";
      # Pin the release/v0.10.0 branch, which is distinct from the v0.10.0 tag.
      rev = "3def4157573fb37cae0bd1b15ffd40b5117ef680";
      hash = "sha256-GkxoPhFXFe9DB5DDs0LdnY2Ip1ooLbuDdReuYc/sr6s=";
    };

    patches = [ ./sqlmux/changes.patch ];

    # The i18n tests scan the source tree, so keep dependencies outside it.
    proxyVendor = true;
    vendorHash = "sha256-y0myQcQDisxd6Upl163txBa+R254qMOjmMIZDxxl8/k=";

    env.CGO_ENABLED = "0";

    subPackages = [ "cmd/sqlmux" ];

    ldflags = [
      "-s"
      "-w"
      "-X main.version=v${version}"
    ];

    checkPhase = ''
      runHook preCheck
      export GOFLAGS=''${GOFLAGS//-trimpath/}
      go test -p "$NIX_BUILD_CORES" ./...
      runHook postCheck
    '';

    nativeInstallCheckInputs = [
      prev.versionCheckHook
    ];
    versionCheckProgramArg = "--version";
    doInstallCheck = true;

    meta = {
      description = "Terminal database client with sessions, split panes, and in-place editing";
      homepage = "https://github.com/kackerx/sqlmux";
      license = prev.lib.licenses.mit;
      maintainers = [ ];
      mainProgram = "sqlmux";
      platforms = prev.lib.platforms.unix;
    };
  };
}
