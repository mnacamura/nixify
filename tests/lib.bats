#!/usr/bin/env bats

set -euo pipefail

# shellcheck source=lib.sh
. "$BATS_TEST_DIRNAME/../lib.sh" >&2

@test "options in usage and help are consistent" {
    local in_usage in_help

    in_usage="$(show_usage \
               | sed 's_\(xify\|\]\) _\1\n_g' \
               | sed -e '/^\[/!d' -e 's/ \[-/\n[-/' \
               | sed -e 's_^\[\(.*\)\]$_\1_' -e 's_^\[__' \
               | awk '{ print $1 }' \
               | sort
               )"
    in_help="$(show_help \
              | sed -e '/^ /!d' -e 's_, _|_' \
              | awk '{ print $1 }' \
              | sort
              )"

    [ "$in_usage" = "$in_help" ]
}

@test "toggle colors for eye candy" {
    local _color _alt_color
    _color="$nixify_color"
    toggle_nixify_color
    _alt_color="$nixify_color"

    [ "$_color" != "$_alt_color" ]

    msg "toggle"
    [ "$nixify_color" = "$_color" ]

    warn "works"
    [ "$nixify_color" = "$_alt_color" ]

    msg "very good"
    [ "$nixify_color" = "$_color" ]
}

@test "fail after prefetch failed" {
    run prefetch_nixpkgs invalidrevhash

    [ ! "$status" -eq 0 ]
    echo "$output" | grep 'prefetching'
    echo "$output" | grep 'failed'
}

