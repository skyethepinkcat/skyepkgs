{
  description = "My Ruby Program";
  nixConfig = {
    extra-substituters = "https://nixpkgs-ruby.cachix.org";
    extra-trusted-public-keys = "nixpkgs-ruby.cachix.org-1:vrcdi50fTolOxWCZZkw0jakOnUI1T19oYJ+PRYdK4SM=";
  };

  inputs = {
    nixpkgs.url = "nixpkgs";
    ruby-nix.url = "github:inscapist/ruby-nix";
    # a fork that supports platform dependant gem
    bundix = {
      url = "github:skyethepinkcat/bundix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ruby-nix,
      bundix,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { pkgs, system, ... }:
        let
          rubyNix = ruby-nix.lib pkgs;

          # TODO generate gemset.nix with bundix
          gemset = if builtins.pathExists ./gemset.nix then import ./gemset.nix else { };

          # If you want to override gem build config, see
          #   https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/ruby-modules/gem-config/default.nix
          gemConfig = { };

          inherit (pkgs) ruby;

          # Running bundix would regenerate `gemset.nix`
          bundixcli = bundix.packages.${system}.default;

          # Use these instead of the original `bundle <mutate>` commands
          bundleLock = pkgs.writeShellScriptBin "bundle-lock" ''
            export BUNDLE_PATH=vendor/bundle
            bundle lock
          '';
          bundleUpdate = pkgs.writeShellScriptBin "bundle-update" ''
            export BUNDLE_PATH=vendor/bundle
            bundle lock --update
          '';
        in
        rec {
          devShells = rec {
            default = dev;
            dev = pkgs.mkShell {
              buildInputs = [
                (rubyNix {
                  inherit gemset ruby;
                  name = "my-ruby-program";
                  gemConfig = pkgs.defaultGemConfig // gemConfig;
                }).env
                bundixcli
                bundleLock
                bundleUpdate
              ]
              ++ (with pkgs; [
                hello
              ]);
            };
          };
        };
    };
}
