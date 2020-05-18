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

  makeOldRelease = { version, sha256 }:
  (self.callPackage ./pkg_old.nix {}).overrideAttrs (_: {
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

  nixify = self.nixify_0_4;

  nixify_0_4 = makeRelease {
    version = "0.4";
    sha256 = "0kmgqznh67zc5nbs2h4fih8jyr55hv7g7j241xw1934i74xvbdpq";
  };

  nixify_0_3_1 = makeRelease {
    version = "0.3.1";
    sha256 = "15nlqpp3fdlwx0vj482i0hj95srpl38n0zaixdnwwfmgp6qjgzab";
  };

  nixify_0_3 = makeRelease {
    version = "0.3";
    sha256 = "0ff3l3w8kgl21iln4x0q40wjxiraxlyjfvkw0i1vpybbw785kzaj";
  };

  nixify_0_2_1 = makeOldRelease {
    version = "0.2.1";
    sha256 = "10mmcd5vq47abc2v3rc34v0pla6w636wwl874hmjrgc8skfd321j";
  };

  nixify_0_2 = makeOldRelease {
    version = "0.2";
    sha256 = "1hfmlgkvj9dl600q46b7pvbhqx4y2s1ikgfh75h0b3r9qqzxlw9d";
  };

  nixify_0_1 = makeOldRelease {
    version = "0.1";
    sha256 = "12razszgz0q7h8fsq2n272ldc6zi45ylh3vawbm5ls7jraxi846v";
  };
}
