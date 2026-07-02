cache:
  nix flake show --json 2>/dev/null \
    | jq  ".packages.$(nix eval nixpkgs#stdenv.hostPlatform.system)|keys[]"\
    | NIXPKGS_ALLOW_UNFREE=1 xargs -I {} nix build --impure .#{} --print-out-paths --no-link \
    | cachix push skyethepinkcat
