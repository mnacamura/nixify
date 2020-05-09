{ pkgs ? import <nixpkgs> {} }:

with pkgs;

callPackage ./pkg.nix {}
