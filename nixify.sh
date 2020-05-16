#!/usr/bin/env bash

set -euo pipefail

nixpkgs_rev=
nixpkgs_sha256=

pkg_pname=
pkg_version=
pkg_build_inputs=()
pkg_native_build_inputs=()

shell_build_inputs=()

is_meowing=

# shellcheck source=lib.sh
. lib.sh

dump_state() {
    echo "\
nixpkgs_rev: $nixpkgs_rev
nixpkgs_sha256: $nixpkgs_sha256
pkg_pname: $pkg_pname
pkg_version: $pkg_version
pkg_build_inputs: ${pkg_build_inputs[*]}
pkg_native_build_inputs: ${pkg_native_build_inputs[*]}
pkg_common_build_inputs: ${pkg_common_build_inputs[*]}
shell_build_inputs: ${shell_build_inputs[*]}\
"
}

parse_args "$@"

cd_project_root

: "${pkg_pname:="$(guess_pkg_pname)"}"
: "${pkg_version:=0.1}"

pkg_common_build_inputs=()
for pkg in "${pkg_build_inputs[@]}" \
           "${pkg_native_build_inputs[@]}"
do
    if ! contains "$pkg" "${pkg_common_build_inputs[@]}"; then
        pkg_common_build_inputs+=("$pkg")
    fi
done

if [ -n "$is_meowing" ]; then
    dump_state
    exit
fi

nix_header="\
{ pkgs ? import <nixpkgs> {} }:

with pkgs;
"

if [ -z "$nixpkgs_rev" ]; then
    if [ -n "$nixpkgs_sha256" ]; then
        warn "option --sha256 is set without option --rev, ignored"
    fi
else
    if [ -z "$nixpkgs_sha256" ]; then
        if ! prefetch_nixpkgs "$nixpkgs_rev"; then
            warn "don't pin nixpkgs"
        fi
    fi
    if [ -n "$nixpkgs_sha256" ]; then
        nix_header="\
let
  nixpkgs = fetchNixpkgs {
    rev = \"$nixpkgs_rev\";
    sha256 = \"$nixpkgs_sha256\";
  };

  fetchNixpkgs = { rev, sha256 }:
  builtins.fetchTarball {
    url = \"https://github.com/NixOS/nixpkgs/archive/\${rev}.tar.gz\";
    inherit sha256;
  };
in

{ pkgs ? import nixpkgs {} }:

with pkgs;
"
    fi
fi

pkg_nix_template="\
{ $(join ', ' stdenv "${pkg_common_build_inputs[@]}") }:

stdenv.mkDerivation rec {
  pname = \"$pkg_pname\";
  version = \"$pkg_version\";

  src = ./.;

  nativeBuildInputs = [ $(join ' ' "${pkg_native_build_inputs[@]}") ];

  buildInputs = [ $(join ' ' "${pkg_build_inputs[@]}") ];
}
"

default_nix_template="\
$nix_header
callPackage ./pkg.nix {}
"

shell_nix_template="\
$nix_header
mkShell {
  inputsFrom = [ (callPackage ./pkg.nix {}) ];

  buildInputs = [ $(join ' ' "${shell_build_inputs[@]}") ];

  shellHook = ''
  '';
}
"

write_text pkg.nix "$pkg_nix_template"
write_text default.nix "$default_nix_template"
write_text shell.nix "$shell_nix_template"
add_gitignore
add_envrc
direnv_allow
