#!/usr/bin/env bats

# shellcheck source=utils.sh
. "$BATS_TEST_DIRNAME/../utils.sh" >&2

setup() {
    set -uo pipefail
}

teardown() {
    set +uo pipefail
}

@test "abbreviate \$HOME by ~" {
    local HOME=/home/hoge
    [ "$(tildify "$HOME/huga/")" = '~/huga/' ]
}

@test "do not abbreviate \$HOME inside path" {
    local HOME=/home/hoge
    [ "$(tildify "/opt$HOME/huga/")" = /opt/home/hoge/huga/ ]
}

@test "join no items to empty" {
    # Below somehow passes even with 'set -u'
    # [ -z "$(join separator)" ]
    local result
    result="$(join separator)"
    [ -z "$result" ]
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
