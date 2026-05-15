final: prev:

let
  version = "2.3.0";
in
{
  toofan = prev.buildGo125Module {
    pname = "toofan";
    inherit version;

    src = prev.fetchFromGitHub {
      owner = "vyrx-dev";
      repo = "toofan";
      tag = "v2.3.0";
      hash = "sha256-dKuW1iCOAZpKc8K4H+VejnOv9nUFwwM3rT5c8dRZaxk=";
    };

    vendorHash = "sha256-YSjJ8NOL97hXZLnfGYIjoKmARv+gWOsv+5qkl9konnA=";

    env.CGO_ENABLED = "0";

    subPackages = [ "." ];

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${version}"
    ];

    doCheck = false;

    nativeInstallCheckInputs = [
      prev.versionCheckHook
    ];
    versionCheckProgramArg = "--version";
    doInstallCheck = true;

    meta = {
      description = "Typing trainer for Persian, Arabic, and Urdu in the terminal";
      homepage = "https://github.com/vyrx-dev/toofan";
      license = prev.lib.licenses.mit;
      maintainers = [ ];
      mainProgram = "toofan";
      platforms = prev.lib.platforms.unix;
    };
  };
}
