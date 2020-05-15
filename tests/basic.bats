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

    msg "toggle"
    [ "$nixify_color" = "$_color" ]

    warn "works"
    [ "$nixify_color" = "$_alt_color" ]

    msg "fine"
    [ "$nixify_color" = "$_color" ]
}

@test "fail after prefetch failed" {
    ! prefetch_nixpkgs invalidrevhash
}

@test "abbreviate \$HOME by ~" {
    local result
    local HOME=/home/hoge

    result="$(abbr_home "$HOME/huga/")"
    [ $? -eq 0 ]

    [ "$result" = '~/huga/' ]
}

@test "do not abbreviate \$HOME inside path" {
    local result
    local HOME=/home/hoge

    result="$(abbr_home "/opt$HOME/huga/")"
    [ $? -eq 0 ]

    [ "$result" = /opt/home/hoge/huga/ ]
}
