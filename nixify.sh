#!/usr/bin/env bash

set -euo pipefail

readonly nixify_name=nixify
readonly nixify_version=0.2.1
readonly nixify_description="\
A little tool to init nix and direnv environment.\
"

nixpkgs_rev=
nixpkgs_sha256=

pkg_pname=
pkg_version=
pkg_build_inputs=()
pkg_native_build_inputs=()

show_usage() {
    echo "\
Usage: $nixify_name \
[-r|--rev REV [--sha256 SHA256]] \
[-n|--pname NAME] \
[-v|--version VERSION] \
[-p|--build-inputs [PKG...]] \
[-P|--native-build-inputs [PKG...]] \
[-h|--help] \
[-V]\
"
}

show_help() {
    show_usage
    echo "
$nixify_description

Options:
    -r, --rev REV                       pin nixpkgs to revision hash REV
        --sha256 SHA256                 sha256 checksum of the pinned nixpkgs (optional)
    -n, --pname NAME                    set package pname to NAME
    -v, --version VERSION               set package version to VERSION
    -p, --build-inputs [PKG...]         set packages in buildInputs
    -P, --native-build-inputs [PKG...]  set packages in nativeBuildInputs
    -h, --help                          show help
    -V                                  show program version\
"
}

show_version() {
    echo "$nixify_version"
}

msg() {
    echo "$nixify_name: $*" >&2
}

warn() {
    echo -e "$nixify_name: \e[33m$*\e[0m" >&2
}

err() {
    echo -e "$nixify_name: \e[31m$*\e[0m" >&2
    exit 1
}

prefetch_nixpkgs() {
    local rev="$1"

    nixpkgs_sha256_memo="$(command mktemp --suffix "$nixify_name")"

    __prefetch_cleanup() {
        command rm -f "$nixpkgs_sha256_memo"
        unset nixpkgs_sha256_memo
        unset -f __prefetch_cleanup
    }

    msg "prefetching nixpkgs rev $rev..."
    local url="https://github.com/NixOS/nixpkgs/archive/$rev.tar.gz"
    if ! command nix-prefetch-url --type sha256 --unpack "$url" \
       | command tee "$nixpkgs_sha256_memo" 1> /dev/null
    then
        warn "...failed"
        __prefetch_cleanup
        return 1
    fi
    nixpkgs_sha256="$(command cat "$nixpkgs_sha256_memo")"
    __prefetch_cleanup
    msg "...done! sha256 is $nixpkgs_sha256"
}

find_git_root() {
    local path="$(command git rev-parse --absolute-git-dir 2> /dev/null)"
    if [ -z "$path" ]; then
       return 1
    fi
    echo "${path%\.git}"
}

abbr_home() {
    if [ -n "${HOME+defined}" ]; then
        echo "$1" | command sed "s@^$HOME@~@"
    else
        echo "$1"
        return 1
    fi
}

cd_project_root() {
    local project_root

    local git_root="$(find_git_root 2> /dev/null)"
    if [ -n "$git_root" ]; then
        msg "guess git repo root $(abbr_home "$git_root") is the project root"
        project_root="$git_root"
    else
        msg "guess current directory is the project root"
        project_root="$PWD"
    fi

    if [ "$project_root" != "$PWD" ]; then
        msg "change working directory to $(abbr_home "$project_root")"
        cd "$project_root"
    fi
}

guess_pkg_pname() {
    command basename "$PWD"
}

add_nix_file() {
    local name="$1" template="$2"

    if [ -e "$name" ]; then
        local bk='~'
        while [ -e "$name$bk" ]; do
            bk="$bk$bk"
        done
        warn "$name exists; renamed to $name$bk"
        command mv "$name" "$name$bk"
    fi

    echo -n "$template" > "$name"
    msg "added $name"
}

add_gitignore() {
    if ! find_git_root 2>&1 > /dev/null; then
        return
    fi

    local comment_line="# Nix and direnv stuff"
    local ignored_files=(.direnv result)

    if [ ! -e .gitignore ]; then
        echo "$comment_line" > .gitignore
        for file in "${ignored_files[@]}"; do
            echo "$file" >> .gitignore
        done
        msg "added .gitignore"
        return
    fi

    if ! command grep "$comment_line" .gitignore 2>&1 > /dev/null; then
        echo >> .gitignore
        echo "$comment_line" >> .gitignore
        for file in "${ignored_files[@]}"; do
            echo "$file" >> .gitignore
        done
        msg "appended lines to .gitignore"
    fi
}

add_envrc() {
    if [ ! -e .envrc ]; then
        echo "use nix" > .envrc
        msg "added .envrc"
        return
    fi

    if ! command grep 'use nix' .envrc 2>&1 > /dev/null; then
        echo "use nix" >> .envrc
        msg "appended 'use nix' to .envrc"
    fi
}

direnv_allow() {
    if ! command direnv allow; then
        warn "skipped executing 'direnv allow'"
    fi
}

pkgs_join() {
    local IFS="$1"
    shift
    echo "$*" | command sed 's/,/, /g'
}

contains() {
    local target="$1"
    shift

    local has_target=
    for elem in "$@"; do
        if [ "$target" == "$elem" ]; then
            has_target=yes
        fi
    done
    test -n "$has_target"
}

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

: ${pkg_pname:="$(guess_pkg_pname)"}
: ${pkg_version:=0.1}

common_build_inputs=()
for pkg in "${pkg_build_inputs[@]}" \
           "${pkg_native_build_inputs[@]}"
do
    if ! contains "$pkg" "${common_build_inputs[@]}"; then
        common_build_inputs+=("$pkg")
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
        if ! prefetch_nixpkgs $nixpkgs_rev; then
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
{ $(pkgs_join ',' stdenv "${common_build_inputs[@]}") }:

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

  buildInputs = [ ];

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
