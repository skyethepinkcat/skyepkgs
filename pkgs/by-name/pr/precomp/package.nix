{
  stdenv,
  fetchFromGitHub,
cmake,
}:
stdenv.mkDerivation rec {
  name = "precomp";
  version = "0.4.7";
  nativeBuildInputs = [
    cmake
  ];
  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];
  src = fetchFromGitHub {
    owner = "schnaader";
    repo = "precomp-cpp";
    rev = "v${version}";
    hash = "sha256-UNU0UuQXivAjZ2XpFreyUuHX8+tjdDOpjSro+3XHma8=";
  };

}
