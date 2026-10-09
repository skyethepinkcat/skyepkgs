{
  fetchFromGitHub,
  stdenv,
unstableGitUpdater,
}:
stdenv.mkDerivation rec {
  name = "iterm2-shell-integration";
  version = "0-unstable-2026-09-20";
  src = fetchFromGitHub {
    owner = "gnachman";
    repo = "iTerm2-shell-integration";
    rev = "bbf5a33cf625ea57df99f8ccc4dff8823044b695";
    hash = "sha256-hlBmPTFyBDNBvmbClyZZPYZ7C+IZodsWU8B+WxHrHjY=";
  };

  dontConfigure = true;
  dontBuild = true;
  passthru.updateScript = unstableGitUpdater {
    branch = "main";
  } ;

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
