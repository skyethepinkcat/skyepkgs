{
  fetchFromGitHub,
  stdenv,
  SDL2,
  bison,
  zlib,
  flex,
  jansson,
  lib,
  withGui ? false,
  gccStdenv,
  coreutils,
  less,
  libpng,
}:
let
  old-nixpkgs = import (fetchTarball {
    # Descriptive name to make the store path easier to identify
    name = "nixos-23.11";
    # Commit hash for nixos-unstable as of 2018-09-12
    url = "https://github.com/NixOS/nixpkgs/archive/205fd4226592cc83fd4c0885a3e4c9c400efabb5.tar.gz";
    sha256 = "sha256-zwVvxrdIzralnSbcpghA92tWu2DV2lwv89xZc8MTrbg=";
  }) { inherit (stdenv.hostPlatform) system; };
  # pkgs = (builtins.getFlake "github:nixos/nixpkgs/nixos-23.11").legacyPackages."${stdenv.system}";
  rev = "479383a";
  userDir = "~/.config/NetHackFourk/";
  binPath = lib.makeBinPath [
    coreutils
    less
  ];
  aimake_flags = lib.strings.join " " [
    (if withGui then "--with=gui" else "--without=gui")
    "--without=jansson"
    "--override-directory gamesdatadir=$out/share/data"
    "--override-directory gamesstatedir=$out/share/save"
    "--override-directory shortcutdir=$out/share/applications"
  ];

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

  patches = [
    ./patch1.patch
  ];
  nativeBuildInputs = [
    zlib
    flex
    bison
    old-nixpkgs.perl
    jansson
  ]
  ++ lib.optionals (withGui) [
    SDL2
    libpng
  ];
  configurePhase = ''
    runHook preConfigure
    patchShebangs --build aimake scripts/*

    runHook postConfigure
  '';
  buildPhase = ''
    runHook preBuild

    mkdir build
    cd build
    ../aimake ${aimake_flags}
    runHook postBuild
  '';
  outputs = [
    "out"
    "man"
  ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out

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
  #   mkdir -p $out/games/lib/nethackuserdir
  #   mv $out/var/games/nhfourk/* $out/games/lib/nethackuserdir
  #
  #   mkdir -p $out/bin
  #   cat <<EOF >$out/bin/nethack
  #   #! ${stdenvUsed.shell} -e
  #   PATH=${binPath}:\$PATH
  #
  #   if [ ! -d ${userDir} ]; then
  #     mkdir -p ${userDir}
  #     cp -r $out/games/lib/nethackuserdir/* ${userDir}
  #     chmod -R +w ${userDir}
  #   fi
  #
  #   RUNDIR=\$(mktemp -d)
  #
  #   cleanup() {
  #     rm -rf \$RUNDIR
  #   }
  #   trap cleanup EXIT
  #
  #   cd \$RUNDIR
  #   for i in ${userDir}/*; do
  #     ln -s \$i \$(basename \$i)
  #   done
  #   for i in $out//lib/nethackdir/*; do
  #     ln -s \$i \$(basename \$i)
  #   done
  #   set +e
  #   $out/games/nethack "\$@"
  #   if [[ \$? -gt 128 ]]; then
  #     echo "nethack exited abnormally, attempting to recover save file..."
  #     ./recover -d . ?lock.0
  #   fi
  #   EOF
  #   chmod +x $out/bin/nethack
  #   ${lib.optionalString x11Mode "mv $out/bin/nethack $out/bin/nethack-x11"}
  #   ${lib.optionalString qtMode "mv $out/bin/nethack $out/bin/nethack-qt"}
  #   install -Dm 555 util/{makedefs,dgn_comp,lev_comp} -t $out/libexec/nethack/
  #   ${lib.optionalString (!(x11Mode || qtMode)) "install -Dm 555 util/dlb -t $out/libexec/nethack/"}
  # '';

}
