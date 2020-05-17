#!/usr/bin/env bats

# shellcheck source=lib.sh
. "$BATS_TEST_DIRNAME/../lib.sh" >&2

setup() {
    set -uo pipefail
    tmpd="$(mktemp -d --suffix "nixifytestdir")"
    pushd "$tmpd"
}

teardown() {
    rm -rf "$tmpd"
    set +uo pipefail
}

@test "write text to a file" {
    run write_text "a.txt" "meow meow"
    echo "$output" | grep "added a.txt"
    grep "meow meow" a.txt
}

@test "back up before writing text to an existing file" {
    touch "b.txt" "b.txt~"
    run write_text "b.txt" "bow bow"
    echo "$output" | grep "renamed to b.txt~~"
    echo "$output" | grep "added b.txt"
    grep "bow bow" b.txt
    [ -e "b.txt~~" ]
}

@test "add .envrc" {
    run add_envrc
    [ "$status" -eq 0 ]
    echo "$output" | grep "added .envrc"
    grep "^use nix$" .envrc
}

@test "append 'use nix' to existing .envrc" {
    echo hello > .envrc
    run add_envrc
    [ "$status" -eq 0 ]
    echo "$output" | grep "appended 'use nix' to .envrc"
    grep "hello" .envrc
    grep "^use nix$" .envrc
}

@test "do not append 'use nix' if .envrc contains it" {
    echo 'use nix' > .envrc
    run add_envrc
    [ "$status" -eq 0 ]
    ! echo "$output" | grep "appended 'use nix' to .envrc"
    grep "^use nix$" .envrc
}
