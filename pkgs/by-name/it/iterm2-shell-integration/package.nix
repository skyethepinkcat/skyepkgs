{
  fetchFromGitHub,
  stdenv,
}:
stdenv.mkDerivation {
  name = "iterm2-shell-integration";
  src = fetchFromGitHub {
    owner = "gnachman";
    repo = "iTerm2-shell-integration";
    rev = "195281b";
    hash = "sha256-x2+5pCz/QOg8Lbuykn7gRJeQ2mhWEupWb16/bNnNxAw=";
  };

  dontConfigure = true;
  dontBuild = true;
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
