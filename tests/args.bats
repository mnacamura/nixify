#!/usr/bin/env bats

set -euo pipefail

# shellcheck source=lib.sh
. "$BATS_TEST_DIRNAME/../lib.sh" >&2

@test "nixpkgs_rev is set" {
    local nixpkgs_rev

    parse_args -r abcdefg
    [ "$nixpkgs_rev" = abcdefg ]

    parse_args --rev hgijklm
    [ "$nixpkgs_rev" = hgijklm ]
}

@test "nixpkgs_sha256 is set" {
    local nixpkgs_sha256

    parse_args --sha256 xxxxxxxxxxxxxxx
    [ "$nixpkgs_sha256" = xxxxxxxxxxxxxxx ]
}

@test "pkg_pname is set" {
    local pkg_pname

    parse_args -n hey
    [ "$pkg_pname" = hey ]

    parse_args --pname wao
    [ "$pkg_pname" = wao ]
}

@test "pkg_version is set" {
    local pkg_version

    parse_args -v 0
    [ "$pkg_version" = 0 ]

    parse_args --version 999
    [ "$pkg_version" = 999 ]
}

@test "*_inputs are set" {
    local pkg_build_inputs pkg_native_build_inputs shell_build_inputs

    parse_args -p a b c -P c d e -s e f
    [ "${pkg_build_inputs[*]}" = "a b c" ]
    [ "${pkg_native_build_inputs[*]}" = "c d e" ]
    [ "${shell_build_inputs[*]}" = "e f" ]

    parse_args \
        --build-inputs A B C \
        --native-build-inputs C D E \
        --shell-build-inputs E F
    [ "${pkg_build_inputs[*]}" = "a b c A B C" ]
    [ "${pkg_native_build_inputs[*]}" = "c d e C D E" ]
    [ "${shell_build_inputs[*]}" = "e f E F" ]
}

@test "project_root is set" {
    local project_root=

    parse_args dest -p a b c
    [ "$project_root" = dest ]
}

@test "project_root is correctly set using --" {
    local project_root=

    parse_args -p a b c -- dest
    [ "$project_root" = dest ]
}
