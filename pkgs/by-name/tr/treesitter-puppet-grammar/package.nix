{
  lib,
  pkgs,

}:
pkgs.tree-sitter.buildGrammar {
  language = "puppet";

}
