{
  bundlerApp,
  bundlerUpdateScript,
  lib,
  makeWrapper,
  openvox-lint,
  puppet-editor-services,
  testers,
}:

(bundlerApp) {
  pname = "puppet-editor-services";
  gemdir = ./.;
  exes = [
    "puppet-languageserver"
    "puppet-debugserver"
    "puppet-languageserver-sidecar"
  ];

  nativeBuildInputs = [
    makeWrapper
    openvox-lint
  ];
  buildInputs = [
    openvox-lint
  ];
  postBuild = ''
    wrapProgram $out/bin/puppet-languageserver --prefix PATH : ${
      lib.makeBinPath [
        openvox-lint
      ]
    }
    wrapProgram $out/bin/puppet-languageserver-sidecar --prefix PATH : ${
      lib.makeBinPath [
        openvox-lint
      ]
    }
    wrapProgram $out/bin/puppet-debugserver --prefix PATH : ${
      lib.makeBinPath [
        openvox-lint
      ]
    }
  '';

  #   puppet
  # ];
  # postBuild = ''
  #   bundle exec rake gem_revendor
  # '';

  passthru = {
    tests.version = testers.testVersion {
      package = puppet-editor-services;
      command = "HOME=$(mktemp -d) puppet-languageserver --version";
      inherit ((import ./gemset.nix).puppet-editor-services) version;
    };
    updateScript = bundlerUpdateScript "puppet-editor-services";
  };

  meta = {
    description = "Puppet Language Server for editors";
    homepage = "https://github.com/puppetlabs/puppet-editor-services";
    changelog = "https://github.com/puppetlabs/puppet-editor-services/blob/main/CHANGELOG.md";
    license = lib.licenses.asl20;
    mainProgram = "puppet-languageserver";
    maintainers = with lib.maintainers; [ skyethepinkcat ];
  };
}
