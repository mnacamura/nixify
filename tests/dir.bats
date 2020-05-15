#!/usr/bin/env bats

set -euo pipefail

# shellcheck source=lib.sh
. "$BATS_TEST_DIRNAME/../lib.sh" >&2

setup() {
    tmpd="$(command mktemp -d --suffix "nixifytestdir")"
    pushd "$tmpd"
}

teardown() {
    popd \
    && command rm -rf "$tmpd"
}

@test "write text to a file" {
    run write_text "a.txt" "meow meow"
    echo "$output" | command grep "added a.txt"
    command grep "meow meow" a.txt
}

@test "back up before writing text to an existing file" {
    touch "b.txt" "b.txt~"
    run write_text "b.txt" "bow bow"
    echo "$output" | command grep "renamed to b.txt~~"
    echo "$output" | command grep "added b.txt"
    command grep "bow bow" b.txt
    [ -e "b.txt~~" ]
}
