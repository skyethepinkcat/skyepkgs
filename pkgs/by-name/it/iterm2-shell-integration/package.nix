{
  fetchFromGitHub,
  stdenv,
  unstableGitUpdater,
}:
stdenv.mkDerivation rec {
  name = "iterm2-shell-integration";
  version = "0-unstable-2026-10-20";
  src = fetchFromGitHub {
    owner = "gnachman";
    repo = "iTerm2-shell-integration";
    rev = "ae52c2d8a1e5b2783f96c642dad4fe69cc55d9cb";
    hash = "sha256-/NjzanNlc+f/3cFGv1d3/JZcdf67jmX+bX1tq+Akd1w=";
  };

  dontConfigure = true;
  dontBuild = true;
  passthru.updateScript = unstableGitUpdater {
    branch = "main";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    find utilities -type f -exec install -Dm755 {} "$out/bin/" \;
    shell_integration_dir="$out/share/iterm2-shell-integration/"
    install -Dm644 shell_integration/zsh $shell_integration_dir/shell-integration.zsh
    install -Dm644 shell_integration/bash $shell_integration_dir/shell-integration.bash
    install -Dm644 shell_integration/fish $shell_integration_dir/shell-integration.fish
    install -Dm644 shell_integration/tcsh $shell_integration_dir/shell-integration.tcsh
    install -Dm644 shell_integration/xonsh $shell_integration_dir/shell-integration.xonsh

    runHook postInstall
  '';
}
