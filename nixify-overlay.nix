self: super:

let
  makeRelease = { version, sha256 }:
  self.nixify-unstable.overrideAttrs (_: {
    inherit version;
    src = self.fetchFromGitHub {
      owner = "mnacamura";
      repo = "nixify";
      rev = version;
      inherit sha256;
    };
  });
in

{
  nixify-unstable = self.callPackage ./pkg.nix {};

  nixify = self.nixify_0_2;

  nixify_0_2 = makeRelease {
    version = "0.2";
    sha256 = "1hfmlgkvj9dl600q46b7pvbhqx4y2s1ikgfh75h0b3r9qqzxlw9d";
  };

  nixify_0_1 = makeRelease {
    version = "0.1";
    sha256 = "12razszgz0q7h8fsq2n272ldc6zi45ylh3vawbm5ls7jraxi846v";
  };
}
