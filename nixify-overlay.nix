self: super:

let
  fetchFromNixifyRepo = { rev, sha256 }:
  self.fetchFromGitHub {
    owner = "mnacamura";
    repo = "nixify";
    inherit rev sha256;
  };
in

rec {
  nixify-unstable = self.callPackage ./pkg.nix {};

  nixify = nixify-unstable.overrideAttrs (_: rec {
    version = "0.1";
    src = fetchFromNixifyRepo {
      rev = version;
      sha256 = "12razszgz0q7h8fsq2n272ldc6zi45ylh3vawbm5ls7jraxi846v";
    };
  });
}
