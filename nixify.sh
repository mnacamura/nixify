#!/usr/bin/env bash

set -euo pipefail

nixpkgs_rev=
nixpkgs_sha256=

pkg_pname=
pkg_version=
pkg_build_inputs=()
pkg_native_build_inputs=()

shell_build_inputs=()

source ./lib.sh

while [ "$#" -gt 0 ]; do
    case "$1" in
        -r|--rev)
            nixpkgs_rev="$2"
            shift; shift
            ;;
        --sha256)
            nixpkgs_sha256="$2"
            shift; shift
            ;;
        -n|--pname)
            pkg_pname="$2"
            shift; shift
            ;;
        -v|--version)
            pkg_version="$2"
            shift; shift
            ;;
        -p|--build-inputs)
            shift
            while [ "$#" -gt 0 ]; do
                case "$1" in
                    -*)
                        break
                        ;;
                    *)
                        pkg_build_inputs+=("$1")
                        shift
                        ;;
                esac
            done
            ;;
        -P|--native-build-inputs)
            shift
            while [ "$#" -gt 0 ]; do
                case "$1" in
                    -*)
                        break
                        ;;
                    *)
                        pkg_native_build_inputs+=("$1")
                        shift
                        ;;
                esac
            done
            ;;
        -s|--shell-build-inputs)
            shift
            while [ "$#" -gt 0 ]; do
                case "$1" in
                    -*)
                        break
                        ;;
                    *)
                        shell_build_inputs+=("$1")
                        shift
                        ;;
                esac
            done
            ;;
        -h|--help)
            show_help
            exit
            ;;
        -V)
            show_version
            exit
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
done

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
{ $(pkgs_join ',' stdenv "${pkg_common_build_inputs[@]}") }:

stdenv.mkDerivation rec {
  pname = \"$pkg_pname\";
  version = \"$pkg_version\";

  src = ./.;

  nativeBuildInputs = [ $(pkgs_join ' ' "${pkg_native_build_inputs[@]}") ];

  buildInputs = [ $(pkgs_join ' ' "${pkg_build_inputs[@]}") ];
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

  buildInputs = [ $(pkgs_join ' ' "${shell_build_inputs[@]}") ];

  shellHook = ''
  '';
}
"

add_nix_file pkg.nix "$pkg_nix_template"
add_nix_file default.nix "$default_nix_template"
add_nix_file shell.nix "$shell_nix_template"
add_gitignore
add_envrc
direnv_allow
