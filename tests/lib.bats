#!/usr/bin/env bats

# shellcheck source=lib.sh
source "$BATS_TEST_DIRNAME/../lib.sh" >&2

@test "options in usage and help are consistent" {
    local in_usage in_help

    in_usage="$(show_usage \
               | command sed 's_\(xify\|\]\) _\1\n_g' \
               | command sed '/^\[/!d' \
               | command sed 's_^\[\(.\+\)\]$_\1_' \
               | command sed 's_\[_\n[_' \
               | command sed 's_^\[\(.\+\)\]$_\1_' \
               | command sed '/^-/!d' \
               | command awk '{ print $1 }' \
               )"
    in_help="$(show_help \
              | command sed '/^ *-/!d' \
              | command sed 's_, -_|-_' \
              | command awk '{ print $1 }' \
              )"

    [ "$in_usage" = "$in_help" ]
}

@test "toggle colors" {
    local _color _alt_color
    _color="$nixify_color"
    toggle_nixify_color
    _alt_color="$nixify_color"

    [ "$_color" != "$_alt_color" ]

    msg "toggle"
    [ "$nixify_color" = "$_color" ]

    warn "works"
    [ "$nixify_color" = "$_alt_color" ]

    msg "fine"
    [ "$nixify_color" = "$_color" ]
}

@test "fail after prefetch failed" {
    run prefetch_nixpkgs invalidrevhash

    [ ! "$status" -eq 0 ]
    echo "$output" | command grep 'prefetching'
    echo "$output" | command grep 'failed'
}
