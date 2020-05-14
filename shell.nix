{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  inputsFrom = [ (callPackage ./pkg.nix {}) ];

  buildInputs = [ shellcheck ];

  shellHook = ''
  '';
}
