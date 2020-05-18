#!/usr/bin/env bats

# shellcheck source=utils.sh
. "$BATS_TEST_DIRNAME/../utils.sh" >&2

setup() {
    set -uo pipefail
}

teardown() {
    set +uo pipefail
}

@test "tildify fails with no argument" {
    run tildify
    [ ! "$status" -eq 0 ]
}

@test "tildify ignores other than the first argument" {
    local HOME=/home/hoge
    [ "$(tildify $HOME/{huga,hoge})" = '~/huga' ]
}

@test "tildify abbreviates \$HOME by ~" {
    local HOME=/home/hoge
    [ "$(tildify $HOME/huga/)" = '~/huga/' ]
}

@test "tildify does not abbreviate \$HOME inside path" {
    local HOME=/home/hoge
    [ "$(tildify /opt$HOME/huga/)" = /opt/home/hoge/huga/ ]
}

@test "strjoin with no separator fails" {
    run strjoin
    [ ! "$status" -eq 0 ]
}

@test "strjoin with no items does not fail" {
    run strjoin sep
    [ "$status" -eq 0 ]
}

@test "strjoin with no items returns empty" {
    [ -z "$(strjoin separator)" ]
}

@test "strjoin handles a lengthy separator" {
   [ "$(strjoin 'aha' pen pineapple apple pen)" = "penahapineappleahaappleahapen" ]
}

@test "strjoin handles empty strings as well" {
    [ "$(strjoin meow '' '_' '')" = "meow_meow" ]
}

@test "contains with no argument fails" {
    run contains
    [ ! "$status" -eq 0 ]
}

@test "contains with one argument fails" {
    run contains it
    [ ! "$status" -eq 0 ]
}

@test "contains pen" {
    run contains pen pineapple apple pen
    [ "$status" -eq 0 ]
}

@test "doesn't contain apple pen" {
    run contains 'apple pen' pineapple apple pen
    [ ! "$status" -eq 0 ]
}

@test "unique with no arguments does not fail" {
    run unique
    [ "$status" -eq 0 ]
}

@test "unique with no arguments produces empty" {
    [ -z "$(unique)" ]
}

@test "uniqued items are different from each other" {
    [ "$(unique a a b b c d a a d b d c)" = "a b c d" ]
}
