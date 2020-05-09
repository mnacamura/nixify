{ stdenvNoCC, fish, coreutils }:

let
  inherit (stdenvNoCC.lib) makeBinPath;
in

stdenvNoCC.mkDerivation {
  pname = "nixify";
  version = "0.0.1";

  src = ./.;

  buildInputs = [ fish coreutils ];

  buildCommand = ''
    install -D $src/nixify.fish $out/bin/nixify
    sed -i $out/bin/nixify -e 's@#!/usr/bin/env fish@#!${fish}/bin/fish@'
  '';
}
