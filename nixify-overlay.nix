self: super:

{
  nixify = self.callPackage ./pkg.nix {};
}
