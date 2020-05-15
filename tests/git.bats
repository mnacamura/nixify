#!/usr/bin/env bats

source lib.sh

setup() {
    tmpd="$(command mktemp -d --suffix ${nixify_name}test)"
    if pushd "$tmpd"; then
        command git init
    fi
}

teardown() {
    if popd; then
        command rm -rf "$tmpd"
    fi
}

@test "ok if git root found" {
    find_git_root
}

@test "fail if git root not found" {
    command rm -rf .git
    ! find_git_root
}

