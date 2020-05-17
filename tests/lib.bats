#!/usr/bin/env bats

set -euo pipefail

# shellcheck source=lib.sh
. "$BATS_TEST_DIRNAME/../lib.sh" >&2

@test "options in usage and help are consistent" {
    local in_usage in_help

    in_usage="$(show_usage \
               | command sed 's_\(xify\|\]\) _\1\n_g' \
               | command sed -e '/^\[/!d' -e 's/ \[-/\n[-/' \
               | command sed -e 's_^\[\(.*\)\]$_\1_' -e 's_^\[__' \
               | command awk '{ print $1 }' \
               | command sort
               )"
    in_help="$(show_help \
              | command sed -e '/^ /!d' -e 's_, _|_' \
              | command awk '{ print $1 }' \
              | command sort
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
    echo "$output" | command grep 'prefetching'
    echo "$output" | command grep 'failed'
}

