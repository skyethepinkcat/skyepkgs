{
  lib,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "opencode-monitor";
  version = "1.0.4";
  pyproject = true;

  src = python3Packages.fetchPypi {
    pname = "opencode_monitor";
    inherit version;
    sha256 = "sha256-oscWPfMNoMA3PbYs87e10JDHoEWM1ytYxXxM9eg9N88=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    click
    rich
    pydantic
    toml
    pyyaml
    prometheus-client
  ];

  meta = {
    description = "Analytics and monitoring tool for OpenCode AI coding sessions";
    homepage = "https://github.com/Shlomob/ocmonitor-share";
    license = lib.licenses.mit;
    mainProgram = "ocmonitor";
    maintainers = with lib.maintainers; [ skyethepinkcat ];
  };
}
