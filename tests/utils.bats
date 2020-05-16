#!/usr/bin/env bats

set -euo pipefail

# shellcheck source=utils.sh
. "$BATS_TEST_DIRNAME/../utils.sh" >&2

@test "abbreviate \$HOME by ~" {
    local HOME=/home/hoge
    [ "$(tildify "$HOME/huga/")" = '~/huga/' ]
}

@test "do not abbreviate \$HOME inside path" {
    local HOME=/home/hoge
    [ "$(tildify "/opt$HOME/huga/")" = /opt/home/hoge/huga/ ]
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

@test "items are different from each other" {
    [ "$(unique a a b b c d a a d b d c)" = "a b c d" ]
}
