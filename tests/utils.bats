#!/usr/bin/env bats

set -euo pipefail

# shellcheck source=utils.sh
. "$BATS_TEST_DIRNAME/../utils.sh" >&2

@test "abbreviate \$HOME by ~" {
    local result HOME=/home/hoge

    result="$(abbr_home "$HOME/huga/")"

    [ $? -eq 0 ]
    [ "$result" = '~/huga/' ]
}

@test "do not abbreviate \$HOME inside path" {
    local result HOME=/home/hoge

    result="$(abbr_home "/opt$HOME/huga/")"

    [ $? -eq 0 ]
    [ "$result" = /opt/home/hoge/huga/ ]
}

@test "join no items to empty" {
   [ "$(join 'separator')" = "" ]
}

@test "join items by a separator of length more than one" {
   [ "$(join 'aha' pen pineapple apple pen)" = "penahapineappleahaappleahapen" ]
}

@test "contains pen, doesn't contain apple pen" {
    contains pen pineapple apple pen
    ! contains 'apple pen' pineapple apple pen
}
