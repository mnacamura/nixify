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

  release_0_2 = makeRelease {
    version = "0.2";
    sha256 = "1hfmlgkvj9dl600q46b7pvbhqx4y2s1ikgfh75h0b3r9qqzxlw9d";
  };

  release_0_1 = makeRelease {
    version = "0.1";
    sha256 = "12razszgz0q7h8fsq2n272ldc6zi45ylh3vawbm5ls7jraxi846v";
  };
}
