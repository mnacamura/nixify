#!/usr/bin/env bats

set -euo pipefail

# shellcheck source=utils.sh
source "$BATS_TEST_DIRNAME/../utils.sh" >&2

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
