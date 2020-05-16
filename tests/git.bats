#!/usr/bin/env bats

set -euo pipefail

# shellcheck source=lib.sh
. "$BATS_TEST_DIRNAME/../lib.sh" >&2

setup() {
    tmpd="$(command mktemp -d --suffix "nixifytestgit")"
    pushd "$tmpd" \
    && command git init
}

teardown() {
    popd \
    && command rm -rf "$tmpd"
}

@test "ok if git root found" {
    gitroot
}

@test "fail if git root not found" {
    command rm -rf .git
    ! gitroot
}

@test "guess git root is the project root" {
    mkdir -p x/y/z
    pushd x/y/z
    run cd_project_root

    echo "$output" | command grep 'guess git repo root'
    echo "$output" | command grep 'change working directory'
}

@test "guess current directory is the project root if not in git repo" {
    command rm -rf .git
    mkdir -p x/y/z
    pushd x/y/z
    run cd_project_root
    popd

    ! echo "$output" | command grep 'change working directory'
}

@test "do not add .gitignore if not in git repo" {
    command rm -rf .git
    run add_gitignore
    [ "$status" -eq 0 ]
    [ ! -e .gitignore ]
}

@test "add .gitignore in git repo" {
    mkdir x && pushd x
    run add_gitignore
    popd
    [ "$status" -eq 0 ]
    echo "$output" | command grep "added .gitignore"
    command cat .gitignore | command grep .direnv
    command cat .gitignore | command grep result
}

@test "append lines to .gitignore if .gitignore exists" {
    echo "pen pineapple" > .gitignore
    run add_gitignore
    [ "$status" -eq 0 ]
    echo "$output" | command grep "appended lines to .gitignore"
    command cat .gitignore | command grep 'pen pineapple'
}
