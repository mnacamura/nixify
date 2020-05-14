{ pkgs ? import <nixpkgs> {} }:

with pkgs.extend (import ./nixify-overlay.nix);

{
  unstable = nixify-unstable;

  release = nixify;
}
