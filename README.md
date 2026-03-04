# skyepkgs

Personal Nix package repository — structured similarly to
[nixpkgs](https://github.com/NixOS/nixpkgs) so that custom packages and
library functions can be imported with minimal boilerplate.

## Repository layout

```
flake.nix                          # Flake entry-point
default.nix                        # Legacy (non-flake) entry-point
overlay.nix                        # nixpkgs overlay exposing all packages
lib/
  default.nix                      # Extended nixpkgs lib (lib.skyepkgs.*)
pkgs/
  default.nix                      # Aggregates all packages
  by-name/                         # nixpkgs-style package tree
    <2-char-prefix>/
      <pname>/
        default.nix                # Package derivation
```

Packages live under `pkgs/by-name/` using the same two-character prefix
convention as nixpkgs (the first two letters of the package name determine its
subdirectory, e.g. `hello-skyepkgs` → `he/hello-skyepkgs/`).

## Adding a package

1. Create a directory `pkgs/by-name/<2-char-prefix>/<pname>/`.
2. Add a `default.nix` derivation inside it (see
   [`pkgs/by-name/he/hello-skyepkgs/default.nix`](pkgs/by-name/he/hello-skyepkgs/default.nix)
   for an example).
3. The package is automatically picked up — no manual registration required.

## Usage

### As a flake

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-unstable";
    skyepkgs.url    = "github:skyethepinkcat/skyepkgs";
    skyepkgs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, skyepkgs, ... }: {
    # 1. Use packages directly
    packages.x86_64-linux.hello = skyepkgs.packages.x86_64-linux.hello-skyepkgs;

    # 2. Or apply the overlay so every skyepkgs package is available via pkgs.*
    nixosConfigurations.mymachine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        { nixpkgs.overlays = [ skyepkgs.overlays.default ]; }
        # ... your other modules
      ];
    };
  };
}
```

### Without flakes

```nix
let
  pkgs     = import <nixpkgs> {};
  skyepkgs = import (builtins.fetchTarball "https://github.com/skyethepinkcat/skyepkgs/archive/main.tar.gz") {
    inherit pkgs;
  };
in
  skyepkgs.hello-skyepkgs
```

Or as an overlay:

```nix
let
  pkgs = import <nixpkgs> {
    overlays = [ (import /path/to/skyepkgs/overlay.nix) ];
  };
in
  pkgs.hello-skyepkgs
```

## Library functions

`lib` is re-exported from the flake and extends the standard nixpkgs `lib` with
a `lib.skyepkgs` attribute set.

```nix
# Access via flake
skyepkgs.lib.skyepkgs.mkMeta { description = "My tool"; }

# Or import directly
lib = import ./lib { inherit (nixpkgs) lib; };
```

### Available helpers (`lib.skyepkgs.*`)

| Function | Description |
|---|---|
| `isValidPackageName name` | Returns `true` if `name` is a non-empty string. |
| `mergePackageSets pkgSets` | Deep-merges a list of package-set attrsets. |
| `mkMeta { ... }` | Constructs a standard `meta` block for a derivation. |

## Building / checking

```sh
# Build all packages
nix flake check

# Build a single package
nix build .#hello-skyepkgs

# Format nix files
nix fmt
```
