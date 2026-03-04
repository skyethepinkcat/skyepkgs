{
  bundlerApp,
  bundlerUpdateScript,
  lib,
  ruby_3_4,
  openvox-lint,
  testers,
}:

(bundlerApp.override { ruby = ruby_3_4; }) {
  pname = "puppet-editor-services";
  gemdir = ./.;
  exes = [
    "puppet-languageserver"
    "puppet-debugserver"
    "puppet-languageserver-sidecar"
  ];

   nativeBuildInputs = [
     ruby_3_4
    openvox-lint
  ];
  #   puppet
  # ];
  # postBuild = ''
  #   bundle exec rake gem_revendor
  # '';

  passthru = {
    tests.version = testers.testVersion {
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
