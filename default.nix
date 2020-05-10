{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  unstable = callPackage ./pkg.nix {};

  makeRelease = { version, sha256 }:
  unstable.overrideAttrs (_: {
    inherit version;
    src = fetchFromGitHub {
      owner = "mnacamura";
      repo = "nixify";
      rev = version;
      inherit sha256;
    };
  });
in

{
  inherit unstable;

  release_0_1 = makeRelease {
    version = "0.1";
    sha256 = "12razszgz0q7h8fsq2n272ldc6zi45ylh3vawbm5ls7jraxi846v";
  };
}
