cache:
  flake show --json 2>/dev/null \
    | jq  ".packages.$(nix eval nixpkgs#stdenv.hostPlatform.system)|keys[]"\
    | xargs -I {} NIXPKGS_ALLOW_UNFREE=1 nix --impure build .#{} --print-out-paths --no-link \
    | cachix push skyethepinkcat
