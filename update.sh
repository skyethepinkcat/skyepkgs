#!/usr/bin/env bash
# Run passthru.updateScript for packages that define one.
# Usage:
#   ./update.sh              # update all packages with updateScript
#   ./update.sh claude       # update specific package(s)
#   ./update.sh --list       # list updatable packages, don't run
set -euo pipefail

FLAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM=$(nix eval --impure --raw --expr 'builtins.currentSystem')

discover_updatable() {
  nix eval --raw "${FLAKE_ROOT}#packages.${SYSTEM}" \
    --apply 'pkgs:
      let names = builtins.attrNames pkgs;
      in builtins.concatStringsSep "\n" (
        builtins.filter (n: pkgs.${n} ? passthru && pkgs.${n}.passthru ? updateScript) names
      )' 2>/dev/null
}

if [[ $# -eq 0 ]]; then
  mapfile -t packages < <(discover_updatable)
elif [[ "$1" == "--list" ]]; then
  discover_updatable
  exit 0
else
  packages=("$@")
fi

if [[ ${#packages[@]} -eq 0 ]]; then
  echo "No packages with updateScript found" >&2
  exit 1
fi

echo "Updating: ${packages[*]}"
for pkg in "${packages[@]}"; do
  echo "==> $pkg"
  nix-update --flake --use-update-script "$pkg"
done
