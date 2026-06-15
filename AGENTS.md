Terse like caveman. Technical substance exact. Only fluff die.
Drop: articles, filler (just/really/basically), pleasantries, hedging.
Fragments OK. Short synonyms. Code unchanged.
Pattern: [thing] [action] [reason]. [next step].
ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift.
Code/commits/PRs: normal. Off: "stop caveman" / "normal mode".

---

# skyepkgs Agent Instructions

## Key commands

```sh
nix flake check --no-build   # fast eval, no build — use for validation
nix flake check              # build everything
nix build .#<pname>          # single package
nix fmt                      # format all .nix files
nix develop                  # dev shell with nixfmt, nix-update, nil
nix-update <pname>           # update package hash/version
```

CI runs `nix flake check --no-build` + format check on every push/PR.

## Critical file layout

- Package file: `pkgs/by-name/<2-char-prefix>/<pname>/package.nix` (NOT `default.nix`)
- Prefix = first 2 chars of pname, e.g. `puppet-editor-services` → `pu/`
- Auto-discovered — no registration needed

## Gotchas

- `vimPlugins` not in `packages` — in `legacyPackages.vimPlugins`. Don't add to `checks`.
- Ruby packages need `Gemfile`, `Gemfile.lock`, `gemset.nix` in package dir. Regenerate: `bundix -l` from package dir. CI auto-regenerates on push to main.
- `callPackage` gets `pkgs // { inherit lib; }` — packages can use `lib.skyepkgs.*`.
- overlay merges `vimPlugins` additively (`prev.vimPlugins // overlay-pkgs.vimPlugins`).

## New package checklist

1. `mkdir pkgs/by-name/<prefix>/<pname>/`
2. Write `package.nix` (see `pkgs/by-name/he/hello-skyepkgs/package.nix`)
3. For Ruby: add `Gemfile`, `Gemfile.lock`, run `bundix -l`
4. Validate: `nix flake check --no-build`
5. Format: `nix fmt`
