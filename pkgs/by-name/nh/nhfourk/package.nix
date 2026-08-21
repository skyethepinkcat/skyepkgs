{
  SDL2,
  coreutils,
  fetchFromGitHub,
  flex,
  jansson,
  less,
  lib,
  libpng,
  perl,
  stdenv,
  zlib,
  bison,
  withGui ? false,
  withServer ? false,
}:
let
  inherit (stdenv.hostPlatform) isDarwin;
  with_flag = name: bool: (if bool then "--with=${name}" else "--without=${name}");
  rev = "479383a";
  userDir = "~/.config/NetHackFourk/";
  binPath = lib.makeBinPath [
    coreutils
    less
  ];
  aimake_flags = lib.strings.join " " [
    (with_flag "gui" withGui)
    (with_flag "server" withServer)
    "--without=jansson"
    "--override-directory gamesbindir=$out"
    "--override-directory gamesdatadir=$out/share/data"
    "--override-directory gamesstatedir=$out/share/save"
    "--override-directory shortcutdir=$out/share/applications"
  ];
  aimake_local = ./aimake.local;
in
stdenv.mkDerivation {
  name = "nhfourk";
  version = "4.3.0.4-${rev}";
  hardeningDisable = [ "format" ];
  src = fetchFromGitHub {
    owner = "tsadok";
    repo = "nhfourk";
    inherit rev;
    hash = "sha256-tfCOFPje9VI4dkJyHTm4InYNePAUsFUfeTszXrUn3BA=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    ./gcc-flag-fix.patch # required for header pre-compiliation to work
    ./aimake-update.patch # pull patches from nethack4 so new perl versions work
  ]
  ++ lib.optionals isDarwin [
    ./darwin-fix.patch # aimake needs to recognize .tbd files as valid libraries on darwin.
  ];
  nativeBuildInputs = [
    zlib
    flex
    bison
    perl
    jansson
  ]
  ++ lib.optionals withGui [
    SDL2
    libpng
  ];

  # We need to throw in some rules to handle .tbd system libraries on darwin systems, that's what
  # this aimake.local file does.
  preConfigure = lib.optionalString isDarwin ''
    cp ${aimake_local} aimake.local
  '';

  configurePhase = ''
    runHook preConfigure
    patchShebangs --build aimake scripts/*

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    mkdir build
    cd build
    mkdir -p $out
    ../aimake ${aimake_flags}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ../aimake --install-only  ${aimake_flags} -i $out

    runHook postInstall
  '';
  postInstall = ''
    mkdir -p $out/bin
    cat <<EOF >$out/bin/nhfourk
    #! ${stdenv.shell} -e
    PATH=${binPath}:\$PATH

    if [ ! -d ${userDir} ]; then
      mkdir -p ${userDir}
      cp -r $out/share/save/* ${userDir}
      chmod -R +w ${userDir}
    fi

    if [ ! -d ${userDir}/saves ]; then
      mkdir -p ${userDir}/saves
      cp -r $out/share/save/* ${userDir}/saves
      chmod -R +w ${userDir}/saves
    fi

    RUNDIR=\$(mktemp -d)

    cleanup() {
      rm -rf \$RUNDIR
    }
    trap cleanup EXIT

    cd \$RUNDIR
    for i in ${userDir}/*; do
      ln -s \$i \$(basename \$i)
    done
    set +e
    $out/nhfourk "\$@"
    if [[ \$? -gt 128 ]]; then
      echo "nhfourk exited abnormally, attempting to recover save file..."
      ./recover -d . ?lock.0
    fi
    EOF
    chmod +x $out/bin/nhfourk
  '';
  meta = {
    description = "A fork of nethack4.";
    mainProgram = "nhfourk";
    maintainers = with lib.maintainers; [ skyethepinkcat ];
  };
}
